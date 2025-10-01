//
//  AccountTransfer.swift
//  SolanaKit
//
//  Created by arsenal on 25.09.25.
//

public struct AccountTransfer: Codable {
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
  }
