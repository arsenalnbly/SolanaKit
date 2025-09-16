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
    
    public init(baseURL: String = "https://pro-api.solscan.io/v2.0/", apiKey: String? = nil) {
        self.baseURL = URL(string: baseURL)!
        self.apiKey = apiKey
    }
    
    private func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let processedData = RentEpochClampInterceptor.processResponseData(data)
        return try JSONDecoder().decode(T.self, from: processedData)
    }
    
    private func executeRequest<T: Decodable>(_ solscanRequest: SolscanRequest, as type: T.Type) async throws -> T {
        guard var urlRequest = solscanRequest.buildURLRequest(with: baseURL) else {
            throw URLError(.badURL)
        }
        if let apiKey = self.apiKey {
            urlRequest.setValue(apiKey, forHTTPHeaderField: "token")
        }
        
        return try await fetch(urlRequest, as: type)
    }
    
    public func getAccountTransactions(address: String, limit: Int? = nil, before: String? = nil) async throws -> SolscanResponse<[AccountTransactions]> {
        let request = SolscanRequest.accountTransactions(address: address, limit: limit, before: before)
        return try await executeRequest(request, as: SolscanResponse<[AccountTransactions]>.self)
    }
    
    public func getAccountDetails(address: String) async throws -> SolanaAccountWrapper? {
        let request = SolscanRequest.accountDetail(address: address)
        let response =  try await executeRequest(request, as: SolscanResponse<AccountDetail>.self)
        
        switch response {
        case .success(success: _, data: let data):
            return SolanaAccountWrapper(data)
        case .error(success: _, errors: let errors):
            print("error retrieving acc details from solscan: \(errors.message)")
            return nil
        }
    }
    
    public func getTransactionDetail(signature: String) async throws -> SolanaTransactionWrapper? {
        let request = SolscanRequest.transactionDetail(signature: signature)
        let response = try await executeRequest(request, as: SolscanResponse<TransactionDetail>.self)
        switch response {
        case .success(success: _, data: let result):
            return SolanaTransactionWrapper(result)
        case .error(success: _, errors: let errors):
            return nil
        }
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
