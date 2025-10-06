//
//  SolanaAccInfo.swift
//  SolanaKit
//
//  Created by arsenal on 11.09.25.
//

public enum AccountData: Codable {
    case array([String])
    case tokenData(TokenData)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let dataArray = try? container.decode([String].self) {
            self = .array(dataArray)
        } else if let tokenData = try? container.decode(TokenData.self) {
            self = .tokenData(tokenData)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Data is neither array of strings nor TokenData"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .array(let array):
            try container.encode(array)
        case .tokenData(let tokenData):
            try container.encode(tokenData)
        }
    }
}

public struct SolanaAccInfo: Codable {
    public let data: AccountData
    public let executable: Bool
    public let lamports: UInt64
    public let owner_program: String
    public let rentEpoch: UInt64
    let space: UInt64

    enum CodingKeys: String, CodingKey {
        case data, executable, lamports, owner, rentEpoch, space
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        data = try container.decode(AccountData.self, forKey: .data)
        executable = try container.decode(Bool.self, forKey: .executable)
        lamports = try container.decode(UInt64.self, forKey: .lamports)
        owner_program = try container.decode(String.self, forKey: .owner)
        rentEpoch = try container.decode(UInt64.self, forKey: .rentEpoch)
        space = try container.decode(UInt64.self, forKey: .space)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(data, forKey: .data)
        try container.encode(executable, forKey: .executable)
        try container.encode(lamports, forKey: .lamports)
        try container.encode(owner_program, forKey: .owner)
        try container.encode(rentEpoch, forKey: .rentEpoch)
        try container.encode(space, forKey: .space)
    }
}

extension SolanaAccInfo {
      public var tokenData: TokenData? {
          if case .tokenData(let data) = self.data {
              return data
          }
          return nil
      }

      public var rawData: [String]? {
          if case .array(let array) = self.data {
              return array
          }
          return nil
      }

      public var isTokenAccount: Bool {
          if case .tokenData = self.data {
              return true
          }
          return false
      }
  }

public struct TokenData : Codable {
    let isNative: Bool
    let mint: String
    let owner: String
    let state: String
    let tokenBalance: String
    let decimals: UInt64
    let uiTokenBalanceString: String
    let space: UInt64
    let program: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case parsed, program, space
    }

    enum ParsedKeys: String, CodingKey {
        case info, type
    }

    enum InfoKeys: String, CodingKey {
        case isNative, mint, owner, state, tokenAmount
    }

    enum AmountKeys: String, CodingKey {
        case amount, decimals, uiAmountString
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode top-level fields
        program = try container.decode(String.self, forKey: .program)
        space = try container.decode(UInt64.self, forKey: .space)

        // Navigate to parsed container
        let parsedContainer = try container.nestedContainer(keyedBy: ParsedKeys.self, forKey: .parsed)
        type = try parsedContainer.decode(String.self, forKey: .type)

        // Navigate to info container
        let infoContainer = try parsedContainer.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        isNative = try infoContainer.decode(Bool.self, forKey: .isNative)
        mint = try infoContainer.decode(String.self, forKey: .mint)
        owner = try infoContainer.decode(String.self, forKey: .owner)
        state = try infoContainer.decode(String.self, forKey: .state)

        // Navigate to tokenAmount container
        let amountContainer = try infoContainer.nestedContainer(keyedBy: AmountKeys.self, forKey: .tokenAmount)
        tokenBalance = try amountContainer.decode(String.self, forKey: .amount)
        decimals = try amountContainer.decode(UInt64.self, forKey: .decimals)
        uiTokenBalanceString = try amountContainer.decode(String.self, forKey: .uiAmountString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode top-level fields
        try container.encode(program, forKey: .program)
        try container.encode(space, forKey: .space)

        // Create parsed container
        var parsedContainer = container.nestedContainer(keyedBy: ParsedKeys.self, forKey: .parsed)
        try parsedContainer.encode(type, forKey: .type)

        // Create info container
        var infoContainer = parsedContainer.nestedContainer(keyedBy: InfoKeys.self, forKey: .info)
        try infoContainer.encode(isNative, forKey: .isNative)
        try infoContainer.encode(mint, forKey: .mint)
        try infoContainer.encode(owner, forKey: .owner)
        try infoContainer.encode(state, forKey: .state)

        // Create tokenAmount container
        var amountContainer = infoContainer.nestedContainer(keyedBy: AmountKeys.self, forKey: .tokenAmount)
        try amountContainer.encode(tokenBalance, forKey: .amount)
        try amountContainer.encode(decimals, forKey: .decimals)
        try amountContainer.encode(uiTokenBalanceString, forKey: .uiAmountString)
    }
}

public struct GetAccountInfoResult: Codable {
    let context: RpcResponseContext
    let value: SolanaAccInfo
}
