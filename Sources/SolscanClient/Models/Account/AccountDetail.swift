//
//  AccountDetail.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

public struct AccountDetail: Codable {
    let account: String
    let lamports: Int
    let type: String
    let executable: Bool
    let owner_program: String
    let rent_epoch: Int
    let is_oncurve: Bool
}
