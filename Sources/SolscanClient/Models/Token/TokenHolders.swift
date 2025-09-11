//
//  TokenHolders.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

import Foundation

public struct TokenHolders: Codable {
    let total: Int
    let items: [TokenHolder]
}

public struct TokenHolder: Codable {
    let address: String
    let amount: Int
    let decimals: Int
    let owner: String
    let rank: Int
    let value: Double
    let percentage: Double
}