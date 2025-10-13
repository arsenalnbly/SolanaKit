//
//  SolanaKit.swift
//  SolanaKit
//
//  Created by arsenal on [date]
//

import Foundation
import Combine
import Solana

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
    @Published public private(set) var splTokens: [TokenAccountInfo]?
    @Published public private(set) var transactions: [AccountTransfer] = []
    @Published public private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published public private(set) var lastSyncTime: Double?
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var isBalanceLoading: Bool = false
    @Published public private(set) var isTransactionsLoading: Bool = false
    @Published public private(set) var syncState: SyncState = .syncing
    @Published public private(set) var error: SolanaKitError?
    @Published public private(set) var currentAccount: String?
    
    // MARK: - Private Properties
    
    nonisolated private let solanaClient: SolanaHttpsClient
    nonisolated private let solscanClient: SolscanHttpsClient
    nonisolated private let cache: TextCacheStore
    //    private var config: SolanaKitConfig
    //    private var autoRefreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Async initialization - waits for all data to be fetched
    public init(
        network: SolanaNetwork = .mainnet,
        solscanAPI: String = "https://pro-api.solscan.io/v2.0/",
        account: String? = nil,
        solscanAPIKey: String = Config.solscanApiKey
    ) async throws {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = cachesPath.appendingPathComponent("SolscanCache", isDirectory: true)
        do {
            self.cache = try await TextCacheStore.createAsync(
                name: "solscan_cache",
                directory: cacheDirectory
            )
        } catch {
            throw SolanaKitError.cacheError(error)
        }
        
        self.solanaClient = SolanaHttpsClient(baseURL: network.rpcURL)
        self.solscanClient = SolscanHttpsClient(baseURL: solscanAPI, apiKey: solscanAPIKey)
        
        if let account = account {
            self.currentAccount = account
            do {
                try await self.loadData()
            } catch {
                throw SolanaKitError.networkError(error)
            }
        }
    }
    
    public init(
        network: SolanaNetwork = .mainnet,
        solscanAPI: String = "https://pro-api.solscan.io/v2.0/",
        account: String? = nil,
        solscanAPIKey: String = Config.solscanApiKey,
        autoLoad: Bool = true
    ) throws {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = cachesPath.appendingPathComponent("SolscanCache", isDirectory: true)
        
        // Initialize cache synchronously
        self.cache = try TextCacheStore(
            name: "solscan_cache",
            directory: cacheDirectory
        )
        
        self.solanaClient = SolanaHttpsClient(baseURL: network.rpcURL)
        self.solscanClient = SolscanHttpsClient(baseURL: solscanAPI, apiKey: solscanAPIKey)
        
        if let account = account {
            self.currentAccount = account
        }
    }
    
    public func loadData() async throws {
        guard currentAccount != nil else { throw SolanaKitError.notConfigured }
        
        isLoading = true
        defer { isLoading = false }
        self.syncState = .syncing
        defer { self.syncState = .synced }
        
        try await refreshBalance()
        try await refreshTransactionHistory()
        try await syncSplTokens()
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
        before: String? = nil,
        forToken: String? = nil,
        sort_order: SolscanHttpsClient.sortOrder = .desc
    ) async throws -> [AccountTransfer] {
        let sorted: [AccountTransfer]
        switch sort_order {
        case .asc:
            sorted = self.transactions.sorted() { $0.block_time < $1.block_time }
        case .desc:
            sorted = self.transactions.sorted() { $0.block_time > $1.block_time }
        }
        if let token = forToken {
            return sorted.filter({ $0.token_address == token })
        }
        
        return sorted
    }
    
    //TODO: Change to getAccountTransfer
    public func refreshTransactionHistory(
        limit: Int = 20,
        from: String? = nil,
        to: String? = nil,
    ) async throws {
        guard let account = currentAccount else { throw SolanaKitError.notConfigured }
        if self.transactions.isEmpty {
            self.transactions = try fetchTransactionsFromCache()
        }
        
        let latest_tx = self.transactions.first?.trans_id
        let latestTransactions = try await self.solanaClient.getTransactions(forAddress: account, until: latest_tx)
        
        switch latestTransactions {
        case .success(_, let result, _):
            if !result.isEmpty {
                let newTransactions = try await fetchTransactionsFromNetwork(limit: limit, until: latest_tx)
                for transaction in newTransactions {
                    self.transactions.insert(transaction, at: 0)
                }
            }
        case .error(_, _, _):
            throw SolanaKitError.networkError(URLError(.badServerResponse))
        }
    }
    
    public func getLatestTxHash() async throws -> String? {
        guard let account = currentAccount else { throw SolanaKitError.notConfigured }
        let latestTx = try await solanaClient.getTransactions(forAddress: account, limit: 1)
        switch latestTx {
        case .success(jsonrpc: _, result: let txs, id: _):
            return txs.first?.signature
        case .error(jsonrpc: _, error: _, id: _):
            return nil
        }
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
    
    public func syncSplTokens() async throws {
        guard let account = currentAccount else { throw SolanaKitError.notConfigured }
        let splTokens = try await solanaClient.getTokenAddressForOwner(programId: PublicKey.tokenProgramId.base58EncodedString, owner: account)
        self.splTokens = splTokens
    }
    
    public func getUnsignedSolTransaction(
        from: String,
        to: String,
        lamports: UInt64
    ) async throws -> Data {
        let recentBlockhash = try await solanaClient.getRecentBlockhash()
        
        guard let senderPublicKey = PublicKey(string: from) else { throw SolanaKitError.invalidAddress }
        guard let recipientPublicKey = PublicKey(string: to) else { throw SolanaKitError.invalidAddress }
        
        let instruction = SystemProgram.transferInstruction(
            from: senderPublicKey,
            to: recipientPublicKey,
            lamports: lamports
        )
        
        var transaction = Transaction(
            feePayer: senderPublicKey,
            instructions: [instruction],
            recentBlockhash: recentBlockhash
        )
        let serializedTx = transaction.serialize(
            requiredAllSignatures: false,
            verifySignatures: false
        )
        switch serializedTx {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    
    public func getUnsignedSplTransaction(
        mintAddress: String,
        from: String,
        destinationAddress: String,
        amount: UInt64,
        decimals: UInt8 = 9,
        allowUnfundedRecipient: Bool = true
    ) async throws -> Data {
        let recentBlockhash = try await solanaClient.getRecentBlockhash()
        
        guard let mint = PublicKey(string: mintAddress) else { throw SolanaKitError.invalidAddress }
        guard let senderOwner = PublicKey(string: from) else { throw SolanaKitError.invalidAddress }
        guard let receiverOwner = PublicKey(string: destinationAddress) else { throw SolanaKitError.invalidAddress }
        
        let senderTokenAccounts = try await solanaClient.getTokenAddressForOwner(mint: mintAddress, owner: from).map { return $0.pubkey }
        var receiverTokenAccounts = try await solanaClient.getTokenAddressForOwner(mint: mintAddress, owner: destinationAddress).map { return $0.pubkey }
        
        var instructions = [TransactionInstruction]()
        if receiverTokenAccounts.isEmpty {
            guard case let .success(associatedAddress) = PublicKey.associatedTokenAddress(
                walletAddress: receiverOwner,
                tokenMintAddress: mint
            ) else {
                throw SolanaKitError.invalidAddress
            }
            instructions.append(
                AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                    mint: mint,
                    associatedAccount: associatedAddress,
                    owner: receiverOwner,
                    payer: senderOwner
                )
            )
            receiverTokenAccounts.append(associatedAddress.base58EncodedString)
        }
        guard let senderAccount = PublicKey(string: senderTokenAccounts.first!) else {
            throw SolanaKitError.invalidAddress
        }
        guard let receiverAccount = PublicKey(string: receiverTokenAccounts.first!) else {
            throw SolanaKitError.invalidAddress
        }
        
        instructions.append(
            TokenProgram.transferCheckedInstruction(
                programId: .tokenProgramId,
                source: senderAccount,
                mint: mint,
                destination: receiverAccount,
                owner: senderOwner,
                multiSigners: [],
                amount: amount,
                decimals: decimals
            )
        )
        var transaction = Transaction(
            feePayer: senderOwner,
            instructions: instructions,
            recentBlockhash: recentBlockhash
        )
        let serializedTx = transaction.serialize(
            requiredAllSignatures: false,
            verifySignatures: false
        )
        switch serializedTx {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
    
    public func broadcastTransaction(signed_tx: Data) async throws -> Bool{
        return try await self.solanaClient.broadcastTransaction(signed_tx: signed_tx)
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
    
    @MainActor
    private func setLoading(_ loading: Bool) {
        self.isLoading = loading
    }
    
    @MainActor
    private func setError(_ error: SolanaKitError) {
        self.error = error
    }
    
    private func fetchBalanceFromNetwork() async throws -> SolanaKitAccount? {
        let accountData = try await solscanClient.getAccountDetails(address: currentAccount!)
        guard !accountData.isEmpty else { return nil }
        guard let account = try solscanClient.parse(accountData, as: AccountDetail.self) else {
            return nil
        }
        try cache.set(accountData, forKey: currentAccount!, type: .account_details)
        return SolanaKitAccount(account)
    }
    
    private func fetchTransactionsFromCache() throws -> [AccountTransfer] {
        let transfersData = try cache.getAllByType(.transaction_history)
        var transfers = [AccountTransfer]()
        for singleData in transfersData {
            if let single_transfer_history = try solscanClient.parse(singleData, as: [AccountTransfer].self) {
                transfers.append(contentsOf: single_transfer_history)
            }
        }
        transfers.sort(by: { $0.block_time > $1.block_time })
        return transfers
    }
    
    private func fetchTransactionsFromNetwork(
        limit: Int = 10,
        from: String? = nil,
        until: String? = nil
    ) async throws -> [AccountTransfer] {
        guard let account = self.currentAccount else { throw SolanaKitError.notConfigured }
        var pageNum = 1
        var finished = false
        var returnTransfers : [AccountTransfer] = []
        let latestTxHash : String
        
        print("Start fetching transactions...")
        while true {
            let key = "\(account).\(limit).\(pageNum)"
            if let transfersData = try cache.get(key), !transfersData.isEmpty {
                if let transfers = try solscanClient.parse(transfersData, as: [AccountTransfer].self) {
                    for transfer in transfers {
                        if let latest_tx = until {
                            finished = transfer.trans_id == latest_tx
                            if finished { break }
                        }
                        returnTransfers.append(transfer)
                    }
                    finished = transfers.count < limit
                }
            } else {
                let transfersData = try await solscanClient.getAccountTransfer(
                    address: account,
                    page: pageNum,
                    page_size: limit
                )
                try cache.set(transfersData, forKey: key, type: .transaction_history)
                if let transfers = try solscanClient.parse(transfersData, as: [AccountTransfer].self){
                    for transfer in transfers {
                        if let latest_tx = until {
                            finished = transfer.trans_id == latest_tx
                            if finished { break }
                        }
                        returnTransfers.append(transfer)
                    }
                    finished = transfers.count < limit
                }
            }
            pageNum += 1
            if finished { break }
        }
        print("Fetching finished")
        return returnTransfers
    }
    
    private func setupAutoRefresh() {}
    
}
