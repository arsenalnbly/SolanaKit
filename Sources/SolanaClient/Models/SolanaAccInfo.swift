//
//  SolanaAccInfo.swift
//  SolanaKit
//
//  Created by arsenal on 11.09.25.
//

public struct SolanaAccInfo: Codable {
    let data: String
    public let executable: Bool
    public let lamports: UInt64
    public let owner: String
    public let rentEpoch: UInt64
    let space: UInt64
}

public struct GetAccountInfoResult: Codable {
    let context: RpcResponseContext
    let value: SolanaAccInfo
}
