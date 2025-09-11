//
//  SolanaRPCResponse.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

enum SolanaRPCResponse<T: Codable>: Codable {
    case success(jsonrpc: String, result: T, id: Int)
    case error(jsonrpc: String, error: SolanaErrorResponse, id: Int)
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc, result, error, id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        let id = try container.decode(Int.self, forKey: .id)
        
        if let result = try container.decodeIfPresent(T.self, forKey: .result) {
            self = .success(jsonrpc: jsonrpc, result: result, id: id)
        } else if let error = try container.decodeIfPresent(SolanaErrorResponse.self, forKey: .error) {
            self = .error(jsonrpc: jsonrpc, error: error, id: id)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Neither result nor error found in response"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .success(let jsonrpc, let result, let id):
            try container.encode(jsonrpc, forKey: .jsonrpc)
            try container.encode(result, forKey: .result)
            try container.encode(id, forKey: .id)
        case .error(let jsonrpc, let error, let id):
            try container.encode(jsonrpc, forKey: .jsonrpc)
            try container.encode(error, forKey: .error)
            try container.encode(id, forKey: .id)
        }
    }
}
