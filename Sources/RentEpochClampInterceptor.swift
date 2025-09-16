//
//  RentEpochClampInterceptor.swift
//  SolanaKit
//
//  Created by arsenal on 12.09.25.
//

import Foundation

internal struct RentEpochClampInterceptor {
    private static let UINT64_MAX_STR = "18446744073709551615"
    private static let LONG_MAX_STR = "9223372036854775807"
    
    static func processResponseData(_ data: Data) -> Data {
        guard let bodyStr = String(data: data, encoding: .utf8) else {
            return data
        }
        
        if bodyStr.contains("\"rent_epoch\"") {
            let range = bodyStr.range(of: "\"rent_epoch\"")
            let startIndex = range?.lowerBound
            let str = bodyStr[startIndex!...]
            let rentEpoch = str.range(of: #"\d+"#, options: .regularExpression).map { String(str[$0]) }
    
            if let rentEpoch = rentEpoch {
                if rentEpoch >= UINT64_MAX_STR {
                    let patched = bodyStr.replacingOccurrences(of: rentEpoch, with: LONG_MAX_STR)
                    return patched.data(using: .utf8)!
                }
            }
        }
    
        return bodyStr.data(using: .utf8)!
    }
}
