//
//  AccountTransfer.swift
//  SolanaKit
//
//  Created by arsenal on 25.09.25.
//

public struct AccountTransfer: Codable {
      let block_id: Int
      let trans_id: String
      let block_time: Int
      let time: String
      let activity_type: String
      let from_address: String
      let to_address: String
      let token_address: String
      let token_decimals: Int
      let amount: Int64
      let flow: String
  }
