//
//  SolanaHttpsClient.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation


@available(macOS 10.15.0, *)
public final class SolanaHttpsClient {
    private let rpcURL: URL
    
    public init(rpcURL: String = "https://api.devnet.solana.com") {
        self.rpcURL = URL(string: rpcURL)!
    }
    
    private func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Endpoints
    
    func getBalance(
        pubkey: String,
        commitment: String = "finalized",
        minContextSlot: Int? = nil
    ) async throws -> SolanaRPCResponse<GetBalanceResult> {
        
        let requestBody = SolanaRPCRequest(
            jsonrpc: "2.0",
            id: 1,
            method: "getBalance",
            params: [
                AnyCodable(pubkey),
                AnyCodable([
                    "commitment": commitment
                ])
            ]
        )
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        return try await fetch(request, as: SolanaRPCResponse<GetBalanceResult>.self)

    }
    
    func getTransaction(
        signature: String,
        commitment: String = "confirmed",
        maxSupportedTransactionVersion: Int = 0,
        encoding: String = "json"
    ) async throws -> SolanaRPCResponse<GetTransactionResult> {
        
        let requestBody = SolanaRPCRequest(
            jsonrpc: "2.0",
            id: 1,
            method: "getTransaction",
            params: [
                AnyCodable(signature),
                AnyCodable([
                    "commitment": commitment,
                    "maxSupportedTransactionVersion": maxSupportedTransactionVersion,
                    "encoding": encoding
                ])
            ]
        )
        
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        return try await fetch(request, as: SolanaRPCResponse<GetTransactionResult>.self)
    }
}

