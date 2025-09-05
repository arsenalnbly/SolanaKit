//
//  RpcResponseContext.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

public struct RpcResponseContext: Codable {
    let apiVersion: String?
    let slot: Int
}
