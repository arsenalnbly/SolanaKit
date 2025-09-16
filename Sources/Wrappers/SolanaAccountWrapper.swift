//
//  SolanaAccountWrapper.swift
//  SolanaKit
//
//  Created by arsenal on 11.09.25.
//

public struct SolanaAccountWrapper {
    let account: String
    let lamports: Int
    let executable: Bool
    let owner_program: String
    let rent_epoch: Int
    
    public init(_ SolscanAcc: AccountDetail) {
        self.account = SolscanAcc.account
        self.lamports = SolscanAcc.lamports
        self.executable = SolscanAcc.executable
        self.owner_program = SolscanAcc.owner_program
        self.rent_epoch = SolscanAcc.rent_epoch
    }
    
    public init(_ SolanaAcc: SolanaAccInfo,_ address: String) {
        self.account = address
        self.lamports = Int(SolanaAcc.lamports)
        self.executable = SolanaAcc.executable
        self.owner_program = SolanaAcc.owner
        self.rent_epoch = Int(SolanaAcc.rentEpoch)
    }
}
