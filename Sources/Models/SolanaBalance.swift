//
//  TokenBalance.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

public struct GetBalanceResult : Codable {
    let context: RpcResponseContext
    let value: UInt64
}

public struct TokenBalance: Codable {
    let accountIndex: Int
    let mint: String
    let owner: String?
    let programId: String?
    let uiTokenAmounnt: UITokenAmount
}

public struct UITokenAmount: Codable {
    let amount: String
    let decimals: Int
    let uiAmount: Int?
    let uiAmountString: String
}
