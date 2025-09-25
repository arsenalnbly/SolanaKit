//
//  SolscanRequest.swift
//  SolanaKit
//
//  Created by arsenal on 10.09.25.
//

import Foundation

struct SolscanRequest {
    let endpoint: String
    let method: HTTPMethod
    let queryParameters: [String: String]?
    let headers: [String: String]
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
    }
    
    init(endpoint: String, method: HTTPMethod = .GET, queryParameters: [String: String]? = nil, apiKey: String? = nil) {
        self.endpoint = endpoint
        self.method = method
        self.queryParameters = queryParameters
        
        var defaultHeaders = [
            "Content-Type": "application/json",
            "User-Agent": "SolanaKit/1.0"
        ]
        
        if let apiKey = apiKey {
            defaultHeaders["token"] = "\(apiKey)"
        }
        
        self.headers = defaultHeaders
    }
    
    func buildURL(with baseURL: URL) -> URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components?.queryItems = queryParameters.compactMap { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        return components?.url
    }
    
    func buildURLRequest(with baseURL: URL) -> URLRequest? {
        guard let url = buildURL(with: baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

extension SolscanRequest {
    static func accountTransactions(address: String, limit: Int? = nil, before: String? = nil) -> SolscanRequest {
        var params: [String: String] = ["address": address]
        
        if let limit = limit {
            params["limit"] = String(limit)
        }
        if let before = before {
            params["before"] = before
        }
        
        return SolscanRequest(
            endpoint: "account/transactions",
            queryParameters: params
        )
    }
    
    static func chainInfo() -> SolscanRequest {
        return SolscanRequest(endpoint: "chaininfo")
    }
    
    static func accountDetail(address: String) -> SolscanRequest {
        let params = ["address": address]
        
        return SolscanRequest(
            endpoint: "account/detail",
            queryParameters: params
        )
    }
    
    static func transactionDetail(signature: String) -> SolscanRequest {
        let params = ["tx": signature]
        
        return SolscanRequest(
            endpoint: "transaction/detail",
            queryParameters: params
        )
    }
    
    static func accountTransfer(
        address: String,
        token_account: String,
        from: String,
        to: String,
        token: String,
        page: Int = 1,
        page_size: Int = 10,
        sort_order: String = "desc"
    ) -> SolscanRequest {
        var params = [
            "address": address,
            "token_account": token_account,
            "from": from,
            "to": to,
            "token": token,
            "page": String(page),
            "page_size": String(page_size),
            "sort_order": sort_order
        ]
        for key in params.keys {
            if params[key]!.isEmpty {
                params.removeValue(forKey: key)
            }
        }
        
        return SolscanRequest(
            endpoint: "account/transfer",
            queryParameters: params
        )
    }
    
    static func tokenHolders(tokenAddress: String, page: Int?, page_size: Int?, from_amount: String?, to_amount: String?) -> SolscanRequest {
        var params: [String: String] = ["address": tokenAddress]
        
        if let page = page {
            params["page"] = String(page)
        }
        if let page_size = page_size {
            params["page_size"] = String(page_size)
        }
        if let from_amount = from_amount {
            params["from_amount"] = from_amount
        }
        if let to_amount = to_amount {
            params["to_amount"] = to_amount
        }
        
        return SolscanRequest(
            endpoint: "token/holders",
            queryParameters: params
        )
    }
}
