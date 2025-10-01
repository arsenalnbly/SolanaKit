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
    
    public func parse<T: Codable>(_ data: Data, as type: T.Type) throws -> T? {
        let processedData = RentEpochClampInterceptor.processResponseData(data)
        let response = try JSONDecoder().decode(SolscanResponse<T>.self, from: processedData)
        switch response {
        case .success(success: _, data: let data):
            return data
        case .error(success: _, errors: let errors):
            return nil
        }
    }
    
    private func executeRequest(_ solscanRequest: SolscanRequest) async throws -> Data {
        guard var urlRequest = solscanRequest.buildURLRequest(with: baseURL) else {
            throw URLError(.badURL)
        }
        if let apiKey = self.apiKey {
            urlRequest.setValue(apiKey, forHTTPHeaderField: "token")
        }
        
        let data = try await fetch(urlRequest)
        return data
    }
    
    public func getAccountTransactions(address: String, limit: Int = 10, before: String? = nil) async throws -> Data {
        let request = SolscanRequest.accountTransactions(address: address, limit: limit, before: before)
        
        var transactions = [SolanaKitTransaction]()
        
        let response = try await executeRequest(request)
        return response
    }
    
    public func getAccountDetails(address: String) async throws -> Data {
        let request = SolscanRequest.accountDetail(address: address)
        let response =  try await executeRequest(request)
        
        return response
    }
    
    public func getTransactionDetail(signature: String) async throws -> Data {
        let request = SolscanRequest.transactionDetail(signature: signature)
        let response = try await executeRequest(request)
        return response
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
    public enum sortOrder: String {
        case asc, desc
    }

    public func getAccountTransfer(
        address: String,
        token_account: String? = nil,
        from: String? = nil,
        to: String? = nil,
        token: String? = nil,
        page: Int = 1,
        page_size: Int = 10,
        sort_order: sortOrder = .desc
    ) async throws -> Data {
        let request = SolscanRequest.accountTransfer(
            address: address,
            token_account: token_account ?? "",
            from: from ?? "",
            to: to ?? "",
            token: token ?? "",
            page: page,
            page_size: page_size,
            sort_order: sort_order.rawValue
        )

        let key = "transfer_\(address)_\(page)_\(page_size)"
        let response = try await executeRequest(request)
        return response
    }
}
