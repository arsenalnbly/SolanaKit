//
//  Transaction.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

public struct GetTransactionResult: Codable {
    let blockTime: Int64
    let meta: TransactionMeta
    let slot: Int64
    let transaction: RPCTransactionStruct
    let version: TransactionVersion?
    
    enum TransactionVersion: Codable {
        case string(String)
        case number(Int)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let intValue = try? container.decode(Int.self) {
                self = .number(intValue)
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Version must be either String or Int"
                    )
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .number(let value):
                try container.encode(value)
            }
        }
    }
}



struct TransactionMeta: Codable {
    let computeUnitsConsumed: Int
    let err: String?
    let fee: Int64
    let innerInstructions: [InnerInstruction]?
    let loadedAddresses: LoadedAddresses
    let logMessages: [String]?
    let postBalances: [Int64]
    let postTokenBalances: [TokenBalance]?
    let preBalances: [Int64]
    let preTokenBalances: [TokenBalance]?
    let rewards: [Reward]
    let status: TransactionStatus
}

struct InnerInstruction: Codable {
    let index: Int
    let instructions: [Instruction]
}

struct LoadedAddresses: Codable {
    let readonly: [String]
    let writable: [String]
}

struct Reward: Codable {
    let pubkey: String
    let lamports: Int64
    let postBalance: UInt64
    let rewardType: String?
    let commission: UInt8?
}

struct TransactionStatus: Codable {
    let Ok: String?
}

struct RPCTransactionStruct: Codable {
    let message: Message
    let signatures: [String]
}

struct Message: Codable {
    let accountKeys: [String]
    let header: MessageHeader
    let instructions: [Instruction]
    let recentBlockhash: String
}

struct MessageHeader: Codable {
    let numReadonlySignedAccounts: Int
    let numReadonlyUnsignedAccounts: Int
    let numRequiredSignatures: Int
}

struct Instruction: Codable {
    let accounts: [Int]
    let data: String
    let programIdIndex: Int
    let stackHeight: Int
}
