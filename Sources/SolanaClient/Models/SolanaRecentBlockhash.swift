//
//  SolanaRecentBlockhash.swift
//  SolanaKit
//
//  Created by arsenal on 02.10.25.
//

import Foundation

public struct RPCBlockhashResult: Codable {
    let context: RpcResponseContext
    let value: SolanaBlockhash
}

public struct SolanaBlockhash: Codable {
    let blockhash: String
    let lastValidBlockHeight: UInt64
}
