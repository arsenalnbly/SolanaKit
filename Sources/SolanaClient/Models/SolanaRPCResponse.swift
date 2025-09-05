//
//  SolanaRPCResponse.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

struct SolanaRPCResponse<T: Codable>: Codable {
    let jsonrpc: String
    let result: T?
    let error: SolanaErrorResponse?
    let id: Int
}
