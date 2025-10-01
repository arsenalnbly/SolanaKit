//
//  AccountTransfer.swift
//  SolanaKit
//
//  Created by arsenal on 25.09.25.
//

public struct AccountTransfer: Codable, Hashable {
    public let block_id: Int
    public let trans_id: String
    public let block_time: Int
    public let time: String
    public let activity_type: String
    public let from_address: String
    public let to_address: String
    public let token_address: String
    public let token_decimals: Int
    public let amount: Int64
    public let flow: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(trans_id)
        hasher.combine(to_address)
        hasher.combine(from_address)
    }
    
    public static func == (lhs: AccountTransfer, rhs: AccountTransfer) -> Bool {
        lhs.trans_id == rhs.trans_id && lhs.to_address == rhs.to_address && lhs.from_address == rhs.from_address
    }
}
