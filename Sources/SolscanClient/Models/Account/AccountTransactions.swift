//
//  AccountTransactions.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

public struct AccountTransactions: Codable {
    let slot: Int
    let fee: Int
    let status: String
    let signer: [String]
    let block_time: Int
    let tx_hash: String
    let parsed_instructions: [ParsedInstruction]
    let program_ids: [String]
    let time: String
}

public struct ParsedInstruction: Codable {
    let type: String
    let program: String
    let program_id: String
}
