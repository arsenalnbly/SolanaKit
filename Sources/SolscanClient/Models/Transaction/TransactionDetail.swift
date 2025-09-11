//
//  TransactionDetail.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

import Foundation

public struct TransactionDetail: Codable {
    let tx_hash: String
    let block_id: Int
    let block_time: Int
    let fee: Int
    let status: Int
    let compute_units_consumed: Int
    let priority_fee: Int
    let reward: Int?
    let sol_bal_change: [SolBalanceChange]?
    let token_bal_change: [TokenBalanceChange]?
    let programs_involved: [String]?
    let parsed_instructions: [ParsedInstruction]?
    let signer: [String]?
    let address_table_lookup: AddressTableLookup?
    let log_message: [String]?
}

public struct SolBalanceChange: Codable {
    let address: String
    let pre_balance: String
    let post_balance: String
    let change_amount: String
}

public struct TokenBalanceChange: Codable {
    let address: String
    let change_type: String
    let change_amount: String
    let decimals: Int
    let post_balance: String
    let pre_balance: String
    let token_address: String
    let owner: String
    let post_owner: String
    let pre_owner: String
}

public struct AddressTableLookup: Codable {
    let account_key: String
    let readonly_indexes: [Int]
    let writable_indexes: [Int]
}
