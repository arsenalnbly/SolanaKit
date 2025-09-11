//
//  ChainInfo.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

public struct ChainInfo: Codable {
    let blockHeight: Int
    let currentEpoch: Int
    let absoluteSlot: Int
    let transactionCount: Int
}
