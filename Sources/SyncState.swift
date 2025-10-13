//
//  SyncState.swift
//  SolanaKit
//
//  Created by arsenal on 13.10.25.
//

public enum SyncState {
    case syncing
    case synced
    case notSynced(Error)
}
