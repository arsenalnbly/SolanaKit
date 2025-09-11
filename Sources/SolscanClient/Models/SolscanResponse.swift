//
//  SolscanResponse.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

public enum SolscanResponse<T: Codable>: Codable {
    case success(success: Bool, data: SuccessResponse)
    case error(success: Bool, errors: ErrorResponse)
    
    enum CodingKeys: String, CodingKey {
        case success, data, errors
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let success = try container.decode(Bool.self, forKey: .success)
        
        if let data = try container.decodeIfPresent(SuccessResponse.self, forKey: .data) {
            self = .success(success: success, data: data)
        } else if let errors = try container.decodeIfPresent(ErrorResponse.self, forKey: .errors) {
            self = .error(success: success, errors: errors)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Neither result nor error found in response"
                )
            )
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
        switch self {
        case .success(let success, let data):
            try container.encode(success, forKey: .success)
            try container.encode(data, forKey: .data)
        case .error(let success, let errors):
            try container.encode(success, forKey: .success)
            try container.encode(errors, forKey: .errors)
        }
    }
    
    public struct SuccessResponse: Codable {
        let total: Int
        let items: [T]
    }
    
    public struct ErrorResponse: Codable {
        let code: Int
        let message: String
    }
}
