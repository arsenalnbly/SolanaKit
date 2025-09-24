//
//  SolscanHttpsClient.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

@available(macOS 10.15.0, *)
public final class SolscanHttpsClient {
    private let baseURL: URL
    private let apiKey: String?
//    private let db: TextCacheStore
    
    public init(baseURL: String = "https://pro-api.solscan.io/v2.0/", apiKey: String? = nil) {
        self.baseURL = URL(string: baseURL)!
        self.apiKey = apiKey
    }
    
    private func fetch(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    private func parse<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        let processedData = RentEpochClampInterceptor.processResponseData(data)
        return try JSONDecoder().decode(T.self, from: processedData)
    }
    
    private func executeRequest<T: Decodable>(_ solscanRequest: SolscanRequest, key: String, as type: T.Type) async throws -> T {
        guard var urlRequest = solscanRequest.buildURLRequest(with: baseURL) else {
            throw URLError(.badURL)
        }
        if let apiKey = self.apiKey {
            urlRequest.setValue(apiKey, forHTTPHeaderField: "token")
        }
//
//        // Check cache first
//        if let fromCache = try db.get(key), !fromCache.isEmpty {
//            return try parse(fromCache, as: type)
//        }
//
        // Cache miss - fetch from network
        let data = try await fetch(urlRequest)
//
//        // Cache the response
//        try db.set(data, forKey: key)

        return try parse(data, as: type)
    }
//    
//    public func close() throws { // DEBUG
//        try db.close()
//    }
    
    public func getAccountTransactions(address: String, limit: Int = 10, before: String? = nil) async throws -> [SolanaKitTransaction] {
        let request = SolscanRequest.accountTransactions(address: address, limit: limit, before: before)
        
        var transactions = [SolanaKitTransaction]()
        let key = "\(address).\(before ?? "").\(limit)"
        
        let response = try await executeRequest(request, key: key, as: SolscanResponse<[AccountTransactions]>.self)
        
        switch response {
        case .success(success: _, data: let data):
            for transaction in data {
//                print("getting data for \(transaction.tx_hash)")
                if let transactionResponse = try await getTransactionDetail(signature: transaction.tx_hash) {
                    transactions.append(transactionResponse)
                }
            }
            return transactions
        case .error(success: _, errors: _):
            return transactions
        }
    }
    
    public func getAccountDetails(address: String) async throws -> SolanaKitAccount? {
        let request = SolscanRequest.accountDetail(address: address)
        let response =  try await executeRequest(request, key: address, as: SolscanResponse<AccountDetail>.self)
        
        switch response {
        case .success(success: _, data: let data):
            return SolanaKitAccount(data)
        case .error(success: _, errors: let errors):
            print("error retrieving acc details from solscan: \(errors.message)")
            return nil
        }
    }
    
    public func getTransactionDetail(signature: String) async throws -> SolanaKitTransaction? {
        let request = SolscanRequest.transactionDetail(signature: signature)
        let response = try await executeRequest(request, key: signature, as: SolscanResponse<TransactionDetail>.self)
        switch response {
        case .success(success: _, data: let result):
            return SolanaKitTransaction(result)
        case .error(success: _, errors: _):
            return nil
        }
    }
    
//    public func getChainInfo() async throws -> SolscanResponse<ChainInfo> {
//        let request = SolscanRequest.chainInfo()
//        return try await executeRequest(request, as: SolscanResponse<ChainInfo>.self)
//    }
//    
//    public func getTokenHolders(
//        tokenAddress: String,
//        page: Int? = nil,
//        pageSize: Int? = nil,
//        fromAmount: String? = nil,
//        toAmount: String? = nil
//    ) async throws -> SolscanResponse<TokenHolders> {
//        let request = SolscanRequest.tokenHolders(
//            tokenAddress: tokenAddress,
//            page: page,
//            page_size: pageSize,
//            from_amount: fromAmount,
//            to_amount: toAmount
//        )
//        return try await executeRequest(request, as: SolscanResponse<TokenHolders>.self)
//    }
}
