//
//  SolanaNetworkClient.swift
//  SolanaKit
//
//  Created by arsenal on 11.09.25.
//

import Foundation

@available(macOS 10.15.0, *)
protocol SolanaClientProtocol {
    associatedtype RequestType
    
    associatedtype SolanaTransactionWrapper
    associatedtype SolanaTransactionHistoryWrapper
    
    var baseURL: URL { get }
    
    init(baseURL: String, apiKey: String?)
    func fetch<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T
    
    func getAccountDetails(address: String) async throws -> SolanaKitAccount
    func getTransactionDetails(signature: String) async throws -> SolanaTransactionWrapper
    func getTransactions(forAddress: String, limit: Int, before: String?, until: String?) async throws -> SolanaTransactionHistoryWrapper
}
