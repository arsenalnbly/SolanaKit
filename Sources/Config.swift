//
//  Config.swift
//  SolanaKit
//
//  Created by arsenal on 12.09.25.
//

import Foundation

public struct Config {
    public static let solscanApiKey: String = {
        guard let key = ProcessInfo.processInfo.environment["SOLSCAN_API_KEY"] else {
            fatalError("SOLSCAN_API_KEY environment variable not set")
        }
        return key
    }()
}
