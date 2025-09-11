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
    
    public init(baseURL: String, apiKey: String? = nil) {
        self.baseURL = URL(string: baseURL)!
        self.apiKey = apiKey
    }
    
    private func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func executeRequest<T: Decodable>(_ solscanRequest: SolscanRequest, as type: T.Type) async throws -> T {
        guard let urlRequest = solscanRequest.buildURLRequest(with: baseURL) else {
            throw URLError(.badURL)
        }
        
        return try await fetch(urlRequest, as: type)
    }
    
    public func getAccountTransactions(address: String, limit: Int? = nil, before: String? = nil) async throws -> SolscanResponse<AccountTransactions> {
        let request = SolscanRequest.accountTransactions(address: address, limit: limit, before: before)
        return try await executeRequest(request, as: SolscanResponse<AccountTransactions>.self)
    }
    
    public func getAccountDetail(address: String) async throws -> SolscanResponse<AccountDetail> {
        let request = SolscanRequest.accountDetail(address: address)
        return try await executeRequest(request, as: SolscanResponse<AccountDetail>.self)
    }
    
    public func getTransactionDetail(signature: String) async throws -> SolscanResponse<TransactionDetail> {
        let request = SolscanRequest.transactionDetail(signature: signature)
        return try await executeRequest(request, as: SolscanResponse<TransactionDetail>.self)
    }
    
    public func getChainInfo() async throws -> SolscanResponse<ChainInfo> {
        let request = SolscanRequest.chainInfo()
        return try await executeRequest(request, as: SolscanResponse<ChainInfo>.self)
    }
    
    public func getTokenHolders(
        tokenAddress: String,
        page: Int? = nil,
        pageSize: Int? = nil,
        fromAmount: String? = nil,
        toAmount: String? = nil
    ) async throws -> SolscanResponse<TokenHolders> {
        let request = SolscanRequest.tokenHolders(
            tokenAddress: tokenAddress,
            page: page,
            page_size: pageSize,
            from_amount: fromAmount,
            to_amount: toAmount
        )
        return try await executeRequest(request, as: SolscanResponse<TokenHolders>.self)
    }
}
