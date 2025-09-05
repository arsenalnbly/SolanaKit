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
        
        let request = try SolanaRPCRequest(
            method: "getBalance",
            params: [
                AnyCodable(pubkey),
                AnyCodable([
                    "commitment": commitment
                ])
            ]
        ).urlRequest(rpcURL)
        
        return try await fetch(request, as: SolanaRPCResponse<GetBalanceResult>.self)

    }
    
    func getTransaction(
        signature: String,
        commitment: String = "confirmed",
        maxSupportedTransactionVersion: Int = 0,
        encoding: String = "json"
    ) async throws -> SolanaRPCResponse<GetTransactionResult> {
        
        let request = try SolanaRPCRequest(
            method: "getTransaction",
            params: [
                AnyCodable(signature),
                AnyCodable([
                    "commitment": commitment,
                    "maxSupportedTransactionVersion": maxSupportedTransactionVersion,
                    "encoding": encoding
                ])
            ]
        ).urlRequest(rpcURL)
        
        return try await fetch(request, as: SolanaRPCResponse<GetTransactionResult>.self)
    }
    
    func getSignaturesForAddress(
        address: String,
        commitment: String = "finalized",
        minContextSlot: Int?,
        limit: Int = 1,
        before: String?,
        until: String?
    ) async throws -> SolanaRPCResponse<[SolanaSignature]> {
        let request = try SolanaRPCRequest(
            method: "getSignaturesForAddress",
            params: [
                AnyCodable(address),
                AnyCodable([
                    "commitment": commitment,
                    "limit": limit
                ])
            ]
        ).urlRequest(rpcURL)
        
        return try await fetch(request, as: SolanaRPCResponse<[SolanaSignature]>.self)
    }
    
    
}

