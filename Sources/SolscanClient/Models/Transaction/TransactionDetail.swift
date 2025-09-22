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
    let reward: [Int]
    let sol_bal_change: [SolBalanceChange]?
    let token_bal_change: [TokenBalanceChange]?
    let programs_involved: [String]?
    let parsed_instructions: [ParsedInstruction]?
    let signer: [String]?
    let address_table_lookup: [AddressTableLookup]?
    let log_message: [String]?
}

//public struct SolBalanceChange: Codable {
//    let address: String
//    let pre_balance: String
//    let post_balance: String
//    let change_amount: String
//}

public struct SolBalanceChange: Codable {
    let address: String
    let pre_balance: String
    let post_balance: String
    let change_amount: String
    
    private enum CodingKeys: String, CodingKey {
        case address
        case pre_balance
        case post_balance
        case change_amount
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .address)
        self.change_amount = try container.decode(String.self, forKey: .change_amount)
        
        // Decode pre_balance
        if let preBalanceString = try? container.decode(String.self, forKey: .pre_balance) {
            self.pre_balance = preBalanceString
        } else if let preBalanceInt = try? container.decode(Int.self, forKey: .pre_balance) {
            self.pre_balance = String(preBalanceInt)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "SolBalaneChange pre_balance must be a string or a number"
                )
            )
        }
        
        // Decode post_balance
        if let postBalanceString = try? container.decode(String.self, forKey: .post_balance) {
            self.post_balance = postBalanceString
        } else if let postBalanceInt = try? container.decode(Int.self, forKey: .post_balance) {
            self.post_balance = String(postBalanceInt)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "SolBalaneChange post_balance must be a string or a number"
                )
            )
        }
    }
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

    private enum CodingKeys: String, CodingKey {
        case address
        case change_type
        case change_amount
        case decimals
        case post_balance
        case pre_balance
        case token_address
        case owner
        case post_owner
        case pre_owner
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.address = try container.decode(String.self, forKey: .address)
        self.change_type = try container.decode(String.self, forKey: .change_type)
        self.change_amount = try container.decode(String.self, forKey: .change_amount)
        self.decimals = try container.decode(Int.self, forKey: .decimals)
        self.token_address = try container.decode(String.self, forKey: .token_address)
        self.owner = try container.decode(String.self, forKey: .owner)
        self.post_owner = try container.decode(String.self, forKey: .post_owner)
        self.pre_owner = try container.decode(String.self, forKey: .pre_owner)

        // Decode pre_balance
        if let preBalanceString = try? container.decode(String.self, forKey: .pre_balance) {
            self.pre_balance = preBalanceString
        } else if let preBalanceInt = try? container.decode(Int.self, forKey: .pre_balance) {
            self.pre_balance = String(preBalanceInt)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "TokenBalanceChange pre_balance must be a string or a number"
                )
            )
        }

        // Decode post_balance
        if let postBalanceString = try? container.decode(String.self, forKey: .post_balance) {
            self.post_balance = postBalanceString
        } else if let postBalanceInt = try? container.decode(Int.self, forKey: .post_balance) {
            self.post_balance = String(postBalanceInt)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "TokenBalanceChange post_balance must be a string or a number"
                )
            )
        }
    }
}

public struct AddressTableLookup: Codable {
    let account_key: String
    let readonly_indexes: [Int]
    let writable_indexes: [Int]
}
