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
    public let activity_type: ActivityType
    public let from_address: String
    public let to_address: String
    public let token_address: String
    public let token_decimals: Int
    public let amount: Int64
    public let flow: String
    
    enum CodingKeys: String, CodingKey {
        case block_id, trans_id, block_time, time, activity_type, from_address, to_address, token_address, token_decimals, amount, flow
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.block_id = try container.decode(Int.self, forKey: .block_id)
        self.trans_id = try container.decode(String.self, forKey: .trans_id)
        self.block_time = try container.decode(Int.self, forKey: .block_time)
        self.time = try container.decode(String.self, forKey: .time)
        self.from_address = try container.decode(String.self, forKey: .from_address)
        self.to_address = try container.decode(String.self, forKey: .to_address)
        self.token_address = try container.decode(String.self, forKey: .token_address)
        self.token_decimals = try container.decode(Int.self, forKey: .token_decimals)
        self.amount = try container.decode(Int64.self, forKey: .amount)
        self.flow = try container.decode(String.self, forKey: .flow)
        self.activity_type = try ActivityType(from: decoder, flow: flow)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(trans_id)
        hasher.combine(to_address)
        hasher.combine(from_address)
    }
    
    public static func == (lhs: AccountTransfer, rhs: AccountTransfer) -> Bool {
        lhs.trans_id == rhs.trans_id && lhs.to_address == rhs.to_address && lhs.from_address == rhs.from_address
    }
}

public enum ActivityType: Codable, Hashable {
    case receive, send, mint, burn, createAccount, closeAccount, other
    
    public init(from decoder: Decoder, flow: String) throws {
        let container = try decoder.container(keyedBy: AccountTransfer.CodingKeys.self)
        
        if let activity = try? container.decode(String.self, forKey: .activity_type) {
            switch activity {
            case "ACTIVITY_SPL_TRANSFER":
                switch flow {
                case "in": self = .receive
                case "out": self = .send
                default: self = .other
                }
            case "ACTIVITY_SPL_CREATE_ACCOUNT":
                self = .createAccount
            case "ACTIVITY_SPL_MINT":
                self = .mint
            case "ACTIVITY_SPL_BURN":
                self = .burn
            case "ACTIVITY_SPL_CLOSE_ACCOUNT":
                self = .closeAccount
            default:
                self = .other
            }
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Couldnt parse activity type"
                )
            )
        }
    }
}
