//
//  SolanaHttpsClient.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation


@available(macOS 10.15.0, *)
public final class SolanaHttpsClient {
    
    typealias RequestType = SolanaRPCRequest
    
    typealias AccountInfoType = SolanaAccInfo
    typealias TransactionDetailsType = SolanaRPCResponse<GetTransactionResult>
    typealias TransactionsType = SolanaRPCResponse<[SolanaSignature]>
    
    internal let baseURL: URL
    
    public init(baseURL: String = "https://api.devnet.solana.com", apiKey: String? = nil) {
        self.baseURL = URL(string: baseURL)!
    }
    
    internal func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let processedData = RentEpochClampInterceptor.processResponseData(data)
        return try JSONDecoder().decode(T.self, from: processedData)
    }
    
    // MARK: - Endpoints
    
    func getAccountDetails(
        address: String
    ) async throws -> SolanaAccountWrapper? {
        
        let request = try SolanaRPCRequest(
            method: "getAccountInfo",
            params: [
                AnyCodable(address)
            ]
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<GetAccountInfoResult>.self)
        var accDetails: SolanaAccInfo?
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return SolanaAccountWrapper(result.value, address)
        case .error(jsonrpc: _, error: let error, id: _):
            return nil
        }
    }
    
    func getTransactionDetails(
        signature: String
    ) async throws -> SolanaTransactionWrapper? {
        
        let request = try SolanaRPCRequest(
            method: "getTransaction",
            params: [
                AnyCodable(signature),
                AnyCodable([
                    "encoding": "json"
                ])
            ]
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<GetTransactionResult>.self)
        let txDetails : SolanaTransactionWrapper?
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return SolanaTransactionWrapper(result, txHash: signature)
        case .error(jsonrpc: _, error: _, id: _):
            return nil
        }
    }
    
    func getTransactions(
        forAddress: String,
        limit: Int = 1,
        before: String?,
        until: String?
    ) async throws -> SolanaRPCResponse<[SolanaSignature]> {
        let request = try SolanaRPCRequest(
            method: "getSignaturesForAddress",
            params: [
                AnyCodable(forAddress),
                AnyCodable([
                    "limit": limit
                ])
            ]
        ).urlRequest(baseURL)
        
        return try await fetch(request, as: SolanaRPCResponse<[SolanaSignature]>.self)
    }
    
    
}
