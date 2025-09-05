//
//  TransactionError.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

enum TransactionError: Codable {
    case instructionError(index: Int, error: InstructionErrorDetail)
    case stringError(String)
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Try decoding string case (e.g. "BlockhashNotFound")
        if let str = try? container.decode(String.self) {
            self = .stringError(str)
            return
        }
        
        // Try decoding object
        if let obj = try? container.decode([String: AnyCodable].self) {
            if let arr = obj["InstructionError"]?.value as? [Any],
               arr.count == 2,
               let idx = arr[0] as? Int {
                
                // Decode inner error detail
                if let detailDict = arr[1] as? [String: Int],
                   let custom = detailDict["Custom"] {
                    self = .instructionError(index: idx, error: .custom(custom))
                    return
                }
            }
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unsupported error format"
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .stringError(let str):
            try container.encode(str)
        case .instructionError(let index, let error):
            let value: [String: AnyCodable] = [
                "InstructionError": AnyCodable([index, error.encodeValue()])
            ]
            try container.encode(value)
        }
    }
}

enum InstructionErrorDetail {
    case custom(Int)
    
    func encodeValue() -> [String: Int] {
        switch self {
        case .custom(let code):
            return ["Custom": code]
        }
    }
}
