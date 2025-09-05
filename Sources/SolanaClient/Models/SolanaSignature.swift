//
//  SolanaSignature.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

public struct SolanaSignature: Codable {
    let signature: String
    let slot: Int
    let err: TransactionError?
    let memo: String?
    let blockTime: Int64?
    let confirmationStatus: String?
}
