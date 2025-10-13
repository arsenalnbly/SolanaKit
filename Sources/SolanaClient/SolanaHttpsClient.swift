//
//  SolanaHttpsClient.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation
import Base58Swift



@available(macOS 10.15.0, *)
public final class SolanaHttpsClient {
    
    private var baseURL: URL
    
    public init(baseURL: String = "https://api.mainnet-beta.solana.com", apiKey: String? = nil) {
        self.baseURL = URL(string: baseURL)!
    }
    
    public func switchNetworkTo(_ network: SolanaNetwork) {
        self.baseURL = URL(string: network.rpcURL)!
    }
    
    private func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        
        let (data, response) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8))
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let processedData = RentEpochClampInterceptor.processResponseData(data)
        return try JSONDecoder().decode(T.self, from: processedData)
    }
    
    // MARK: - Endpoints
    
    func broadcastTransaction(signed_tx: Data) async throws -> Bool {
        let txBase58 = Base58.base58Encode([UInt8](signed_tx))
        let request = try SolanaRPCRequest(
            method: "sendTransaction",
            params: [AnyCodable(txBase58)]
        ).urlRequest(baseURL)
        let response = try await fetch(request, as: SolanaRPCResponse<String>.self)
        switch response {
        case .success(jsonrpc: _, result: let sig, id: _):
            if !Base58.base58Decode(sig)!.containsSubarray([UInt8](signed_tx)) {
                return false
            }
            return true
        case .error(jsonrpc: _, error: let error, id: _):
            throw error
        }
    }
    
    func getRecentBlockhash() async throws -> String {
        let request = try SolanaRPCRequest(
            method: "getLatestBlockhash",
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<RPCBlockhashResult>.self)
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return result.value.blockhash
        case .error(jsonrpc: _, error: let error, id: _):
            throw error
        }
    }
    
    func getTokenAddressForOwner(
        programId: String,
        owner: String
    ) async throws -> [TokenAccountInfo] {
        let request = try SolanaRPCRequest(
            method: "getTokenAccountsByOwner",
            params: [
                AnyCodable(owner),
                AnyCodable(["programId" : programId]),
                AnyCodable(["encoding" : "jsonParsed"])
            ]
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<GetTokenAccountResult>.self)
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return result.value
        case .error(jsonrpc: _, error: let error, id: _):
            throw error
        }
    }
    
    func getTokenAddressForOwner(
        mint: String,
        owner: String
    ) async throws -> [TokenAccountInfo] {
        let request = try SolanaRPCRequest(
            method: "getTokenAccountsByOwner",
            params: [
                AnyCodable(owner),
                AnyCodable(["mint" : mint]),
                AnyCodable(["encoding" : "jsonParsed"])
            ]
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<GetTokenAccountResult>.self)
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return result.value
        case .error(jsonrpc: _, error: let error, id: _):
            throw error
        }
    }
    
    func getAccountDetails(
        address: String
    ) async throws -> SolanaKitAccount? {
        
        let request = try SolanaRPCRequest(
            method: "getAccountInfo",
            params: [
                AnyCodable(address),
                AnyCodable(["encoding" : "jsonParsed"])
            ]
        ).urlRequest(baseURL)
        
        let response = try await fetch(request, as: SolanaRPCResponse<GetAccountInfoResult>.self)
        var accDetails: SolanaAccInfo?
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return SolanaKitAccount(result.value, address)
        case .error(jsonrpc: _, error: let error, id: _):
            return nil
        }
    }
    
    func getTransactionDetails(
        signature: String
    ) async throws -> SolanaKitTransaction? {
        
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
        let txDetails : SolanaKitTransaction?
        switch response {
        case .success(jsonrpc: _, result: let result, id: _):
            return SolanaKitTransaction(result, txHash: signature)
        case .error(jsonrpc: _, error: _, id: _):
            return nil
        }
    }
    
    func getTransactions(
        forAddress: String,
        limit: Int = 10,
        before: String? = nil,
        until: String? = nil
    ) async throws -> SolanaRPCResponse<[SolanaSignature]> {
        var options: [String: Any] = [
            "limit": limit
        ]

        if let before = before, !before.isEmpty {
            options["before"] = before
        }

        if let until = until, !until.isEmpty {
            options["until"] = until
        }

        let request = try SolanaRPCRequest(
            method: "getSignaturesForAddress",
            params: [
                AnyCodable(forAddress),
                AnyCodable(options)
            ]
        ).urlRequest(baseURL)

        return try await fetch(request, as: SolanaRPCResponse<[SolanaSignature]>.self)
    }
    
    
}

extension Array where Element: Equatable {
    func containsSubarray(_ subarray: [Element]) -> Bool {
        guard !subarray.isEmpty else { return true }
        guard subarray.count <= self.count else { return false }
        
        return (0...(self.count - subarray.count)).contains { i in
            self[i...].starts(with: subarray)
        }
    }
}
