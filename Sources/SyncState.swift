//
//  SyncState.swift
//  SolanaKit
//
//  Created by arsenal on 13.10.25.
//

public enum SyncState : Equatable {
    public static func == (lhs: SyncState, rhs: SyncState) -> Bool {
        switch (lhs, rhs) {
        case (.syncing, .syncing):
            return true
        case (.synced, .synced):
            return true
        case (.notSynced(_), .notSynced(_)):
            return true
        default:
            return false
        }
    }
    
    case syncing
    case synced
    case notSynced(Error)
}
