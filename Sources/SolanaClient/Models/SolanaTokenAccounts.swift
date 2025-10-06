//
//  SolanaTokenAccounts.swift
//  SolanaKit
//
//  Created by arsenal on 02.10.25.
//

import Foundation

public struct GetTokenAccountResult : Codable {
    let context: RpcResponseContext
    let value: [TokenAccountInfo]
}

public struct TokenAccountInfo: Codable, Sendable {
    public let pubkey: String
    public let account: SolanaAccInfo
}

//struct TokenAccountInfo: Codable {
//    let pubkey: String
//    let lamports: Int64
//    let isNative: Bool
//    let mint: String
//    let owner: String
//    let state: String
//    let amount: String
//    let decimals: Int
//    let uiAmount: Double
//    let uiAmountString: String
//    
//    enum CodingKeys: String, CodingKey {
//        case pubkey
//        case account
//    }
//    
//    enum AccountKeys: String, CodingKey {
//        case lamports
//        case data
//    }
//    
//    enum DataKeys: String, CodingKey {
//        case parsed
//    }
//    
//    enum ParsedKeys: String, CodingKey {
//        case info
//    }
//    
//    enum InfoKeys: String, CodingKey {
//        case isNative, mint, owner, state, tokenAmount
//    }
//    
//    enum TokenAmountKeys: String, CodingKey {
//        case amount, decimals, uiAmount, uiAmountString
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        // Get pubkey at root level
//        pubkey = try container.decode(String.self, forKey: .pubkey)
//        
//        // Navigate to account
//        let accountContainer = try container.nestedContainer(keyedBy: AccountKeys.self, forKey: .account)
//        lamports = try accountContainer.decode(Int64.self, forKey: .lamports)
//        
//        // Navigate to data.parsed.info
//        let dataContainer = try accountContainer.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
//        let parsedContainer = try dataContainer.nestedContainer(keyedBy: ParsedKeys.self, forKey: .parsed)
//        let infoContainer = try parsedContainer.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
//        
//        // Decode info fields
//        isNative = try infoContainer.decode(Bool.self, forKey: .isNative)
//        mint = try infoContainer.decode(String.self, forKey: .mint)
//        owner = try infoContainer.decode(String.self, forKey: .owner)
//        state = try infoContainer.decode(String.self, forKey: .state)
//        
//        // Decode tokenAmount
//        let tokenAmountContainer = try infoContainer.nestedContainer(keyedBy: TokenAmountKeys.self, forKey: .tokenAmount)
//        amount = try tokenAmountContainer.decode(String.self, forKey: .amount)
//        decimals = try tokenAmountContainer.decode(Int.self, forKey: .decimals)
//        uiAmount = try tokenAmountContainer.decode(Double.self, forKey: .uiAmount)
//        uiAmountString = try tokenAmountContainer.decode(String.self, forKey: .uiAmountString)
//    }
//    
//    // MARK: - Encode
//          public func encode(to encoder: Encoder) throws {
//              var container = encoder.container(keyedBy: CodingKeys.self)
//
//              // Encode pubkey at root level
//              try container.encode(pubkey, forKey: .pubkey)
//
//              // Create account container
//              var accountContainer = container.nestedContainer(keyedBy: AccountKeys.self, forKey: .account)
//              try accountContainer.encode(lamports, forKey: .lamports)
//
//              // Create data.parsed.info structure
//              var dataContainer = accountContainer.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
//              var parsedContainer = dataContainer.nestedContainer(keyedBy: ParsedKeys.self, forKey: .parsed)
//              var infoContainer = parsedContainer.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
//
//              // Encode info fields
//              try infoContainer.encode(isNative, forKey: .isNative)
//              try infoContainer.encode(mint, forKey: .mint)
//              try infoContainer.encode(owner, forKey: .owner)
//              try infoContainer.encode(state, forKey: .state)
//
//              // Encode tokenAmount
//              var tokenAmountContainer = infoContainer.nestedContainer(keyedBy: TokenAmountKeys.self, forKey: .tokenAmount)
//              try tokenAmountContainer.encode(amount, forKey: .amount)
//              try tokenAmountContainer.encode(decimals, forKey: .decimals)
//              try tokenAmountContainer.encode(uiAmount, forKey: .uiAmount)
//              try tokenAmountContainer.encode(uiAmountString, forKey: .uiAmountString)
//          }
//}
