//
//  SolanaRPCRequest.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

struct SolanaRPCRequest: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: [AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc, id, method, params
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        if let params = self.params, !params.isEmpty {
            try container.encode(params, forKey: .params)
        }
    }
    
    init(jsonrpc: String = "2.0", id: Int = 1, method: String, params: [AnyCodable]? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.method = method
        self.params = params
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        id = try container.decode(Int.self, forKey: .id)
        method = try container.decode(String.self, forKey: .method)
        params = try container.decode([AnyCodable].self, forKey: .params)
    }
    
    func urlRequest(_ url: URL) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(self)
        
        return request
    }
}
