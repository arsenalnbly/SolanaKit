//
//  SolanaErrorResponse.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

public struct SolanaErrorResponse: Codable, Error {
    let code: Int
    let message: String
}
