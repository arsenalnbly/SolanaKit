//
//  SolanaKit.swift
//  SolanaKit
//
//  Created by arsenal on [date]
//

import Foundation
import Combine

// MARK: - Configuration

public enum SolanaNetwork {
    case mainnet
    case devnet
    case testnet
    
    var rpcURL: String {
        switch self {
        case .mainnet: return "https://api.mainnet-beta.solana.com"
        case .devnet: return "https://api.devnet.solana.com"
        case .testnet: return "https://api.testnet.solana.com"
        }
    }
}

public enum ConnectionStatus {
    case connected
    case disconnected
    case error(Error)
}

//public struct SolanaKitConfig {
//    public var cacheTimeout: TimeInterval = 300
//    public var maxTransactionHistory: Int = 100
//    public var autoRefreshInterval: TimeInterval? = nil
//    public var fallbackToSolscan: Bool = true
//    public var network: SolanaNetwork = .mainnet
//    
//    public init() {}
//}

public struct SolanaKitSyncResult {
    public let balance: SolanaKitAccount?
    public let transactions: [SolanaKitTransaction]
    public let syncTime: Date
}

public enum SolanaKitError: Error {
    case notConfigured
    case networkError(Error)
    case invalidAddress
    case cacheError(Error)
}

// MARK: - Main SolanaKit Class

@available(macOS 10.15.0, *)
public final class SolanaKit: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var balance: SolanaKitAccount?
    @Published public private(set) var transactions: [SolanaKitTransaction] = []
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published public private(set) var lastSyncTime: Double?
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var isBalanceLoading: Bool = false
    @Published public private(set) var isTransactionsLoading: Bool = false
    @Published public private(set) var error: SolanaKitError?
    @Published public private(set) var currentAccount: String?
    
    // MARK: - Private Properties
    
    nonisolated private let solanaClient: SolanaHttpsClient
    nonisolated private let solscanClient: SolscanHttpsClient
    private let cache: TextCacheStore
//    private var config: SolanaKitConfig
//    private var autoRefreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        network: SolanaNetwork = .mainnet,
        solscanAPI: String = "https://pro-api.solscan.io/v2.0/",
//        config: SolanaKitConfig = SolanaKitConfig()
        account: String? = nil
    ) async throws {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = cachesPath.appendingPathComponent("SolscanCache", isDirectory: true)
        self.cache = try TextCacheStore(
            name: "solscan_cache",
            directory: cacheDirectory,
        )
        
        self.solanaClient = SolanaHttpsClient(baseURL: network.rpcURL)
        self.solscanClient = SolscanHttpsClient(baseURL: solscanAPI, apiKey: Config.solscanApiKey)
        
        if let account = account {
            self.currentAccount = account
            try await self.refreshBalance()
            try await self.refreshTransactionHistory()
        }
        
    }
    deinit { try? self.cache.close() }
    
    // MARK: - Configuration
    
    @MainActor
    public func configure(account: String) async throws {
        self.currentAccount = account
        self.balance = try await self.getCurrentBalance()
        self.transactions = try await self.getTransactionHistory()
    }
    
    @MainActor
    public func switchNetwork(_ network: SolanaNetwork) {
        self.solanaClient.switchNetworkTo(network)
    }
    
//    public func updateConfig(_ newConfig: SolanaKitConfig) {}
    
    // MARK: - Balance Management
    
    @MainActor
    public func getCurrentBalance() async throws -> SolanaKitAccount? {
        return self.balance
    }
    
    public func refreshBalance() async throws {
        self.isBalanceLoading = true
        defer { isBalanceLoading = false}
        
        let newBalance = try await self.fetchBalanceFromNetwork()
        self.balance = newBalance
    }
    
    // MARK: - Transaction History
    
    @MainActor
    public func getTransactionHistory(
        limit: Int = 10,
        before: String? = nil
    ) async throws -> [SolanaKitTransaction] {
        return self.transactions
    }
    
    //TODO: Change to getAccountTransfer
    public func refreshTransactionHistory(
        limit: Int = 10,
        before: String? = nil
    ) async throws {
        guard let account = currentAccount else { throw SolanaKitError.notConfigured }
        let transactionsData = try await solscanClient.getAccountTransactions(address: account, limit: limit, before: before)
        
        guard let transactions = try solscanClient.parse(transactionsData, as: [AccountTransactions].self) else {
            return
        }

        guard let latestTx = transactions.first?.tx_hash else {
            return
        }
        try cache.set(transactionsData, forKey: "\(account).\(before ?? "").\(limit).\(latestTx)", type: .transaction_history)
        if self.transactions.contains(where: {
            $0.txHash == latestTx
        }) {
            return
        }
        var index: Int = 0
        for transaction in transactions {
            if self.transactions.contains(where: {
                $0.txHash == transaction.tx_hash
            }) {
                continue
            }
            let transactionData : Data
            if cache.contains(transaction.tx_hash) {
                transactionData = try cache.get(transaction.tx_hash)!
            } else {
                transactionData = try await solscanClient.getTransactionDetail(signature: transaction.tx_hash)
                try cache.set(transactionData, forKey: transaction.tx_hash, type: .transaction_details)
            }
            let parsedTransaction = try solscanClient.parse(transactionData, as: TransactionDetail.self)
            self.transactions.insert(SolanaKitTransaction(parsedTransaction!), at: index)
            index += 1
        }
        
    }
    
    public func getLatestTxHash() async throws -> String? {
        guard let account = currentAccount else { throw SolanaKitError.notConfigured }
        let transactionsData = try await solscanClient.getAccountTransactions(address: account)
        
        guard var transactions = try solscanClient.parse(transactionsData, as: [AccountTransactions].self) else {
            return nil
        }

        return transactions.first?.tx_hash
    }
    
    public func getTransactionDetails(signature: String) async throws -> SolanaKitTransaction? {
        return nil
    }
    
    // MARK: - Data Synchronization
    
    @MainActor
    public func syncAll() async throws {
        
        
    }
    
    public func isDataStale(threshold: TimeInterval? = nil) -> Bool {
        guard let threshold = threshold else { return false }
        guard let lastSyncTime = self.lastSyncTime else { return false }
        
        let now = Date().timeIntervalSince1970
        return now - lastSyncTime > threshold
    }
    
    // MARK: - Cache Management
    
    @MainActor
    public func clearCache() throws {
        try self.cache.removeAll()
    }
    
    public func setCacheTimeout(_ timeout: TimeInterval) {}
    
    // MARK: - Utility Methods
    
    public static func lamportsToSOL(_ lamports: UInt64) -> Double {
        return Double(lamports) / 1_000_000_000.0
    }
    
    public static func solToLamports(_ sol: Double) -> UInt64 {
        return UInt64(sol * 1_000_000_000.0)
    }
    
    public static func formatBalance(_ balance: UInt64, decimals: Int = 9) -> String {
        let sol = lamportsToSOL(balance)
        return String(format: "%.9f", sol)
    }
    
    public func validateAddress(_ address: String) -> Bool {
        return !address.isEmpty && address.count >= 32 && address.count <= 44
    }
    
    // MARK: - Private Helper Methods
    
    private func ensureConfigured() throws {}
    
    private func fetchBalanceFromNetwork() async throws -> SolanaKitAccount? {
        let accountData = try await solscanClient.getAccountDetails(address: currentAccount!)
        guard !accountData.isEmpty else { return nil }
        guard let account = try solscanClient.parse(accountData, as: AccountDetail.self) else {
            return nil
        }
        try cache.set(accountData, forKey: currentAccount!, type: .account_details)
        return SolanaKitAccount(account)
    }
    
    private func fetchTransactionsFromNetwork(
        limit: Int = 10,
        before: String? = nil
    ) async throws -> [SolanaKitTransaction] {
        return [SolanaKitTransaction]()
    }
    
    private func setupAutoRefresh() {}
    
}
