//
//  SolanaTransactionWrapper.swift
//  SolanaKit
//
//  Created by arsenal on 11.09.25.
//

import Foundation

public struct SolanaKitTransaction: Sendable {
    let txHash: String
    let blockTime: Int64
    let slot: Int64?
    let fee: Int64
    let status: String
    let computeUnitsConsumed: Int
    let priorityFee: Int?
    let signers: [String]
    let programsInvolved: [String]
    let logMessages: [String]?
    let solBalanceChanges: [SolBalanceChangeWrapper]?
    let tokenBalanceChanges: [TokenBalanceChangeWrapper]?
    let parsedInstructions: [ParsedInstructionWrapper]?

    public init(_ solscanTx: TransactionDetail) {
        self.txHash = solscanTx.tx_hash
        self.blockTime = Int64(solscanTx.block_time)
        self.slot = Int64(solscanTx.block_id)
        self.fee = Int64(solscanTx.fee)
        self.status = solscanTx.status == 1 ? "Success" : "Failed"
        self.computeUnitsConsumed = solscanTx.compute_units_consumed
        self.priorityFee = solscanTx.priority_fee
        self.signers = solscanTx.signer ?? []
        self.programsInvolved = solscanTx.programs_involved ?? []
        self.logMessages = solscanTx.log_message
        self.solBalanceChanges = solscanTx.sol_bal_change?.map { SolBalanceChangeWrapper($0) }
        self.tokenBalanceChanges = solscanTx.token_bal_change?.map { TokenBalanceChangeWrapper($0) }
        self.parsedInstructions = solscanTx.parsed_instructions?.map { ParsedInstructionWrapper($0) }
    }

    public init(_ solanaTx: GetTransactionResult, txHash: String) {
        self.txHash = txHash
        self.blockTime = solanaTx.blockTime
        self.slot = solanaTx.slot
        self.fee = solanaTx.meta.fee
        self.status = solanaTx.meta.err == nil ? "Success" : "Failed"
        self.computeUnitsConsumed = solanaTx.meta.computeUnitsConsumed
        self.priorityFee = nil
        self.signers = Array(solanaTx.transaction.message.accountKeys[..<solanaTx.transaction.message.header.numRequiredSignatures])
        self.programsInvolved = solanaTx.transaction.message.accountKeys
        self.logMessages = solanaTx.meta.logMessages
        self.solBalanceChanges = Self.createSolBalanceChanges(from: solanaTx)
        self.tokenBalanceChanges = Self.createTokenBalanceChanges(from: solanaTx)
        self.parsedInstructions = nil
    }

    private static func createSolBalanceChanges(from tx: GetTransactionResult) -> [SolBalanceChangeWrapper]? {
        let preBalances = tx.meta.preBalances
        let postBalances = tx.meta.postBalances
        let accountKeys = tx.transaction.message.accountKeys

        guard preBalances.count == postBalances.count,
              accountKeys.count >= preBalances.count else { return nil }

        var changes: [SolBalanceChangeWrapper] = []
        for i in 0..<preBalances.count {
            if i < accountKeys.count {
                let change = SolBalanceChangeWrapper(
                    address: accountKeys[i],
                    preBalance: String(preBalances[i]),
                    postBalance: String(postBalances[i]),
                    changeAmount: String(postBalances[i] - preBalances[i])
                )
                changes.append(change)
            }
        }
        return changes.isEmpty ? nil : changes
    }

    private static func createTokenBalanceChanges(from tx: GetTransactionResult) -> [TokenBalanceChangeWrapper]? {
        guard let preTokenBalances = tx.meta.preTokenBalances,
              let postTokenBalances = tx.meta.postTokenBalances else { return nil }

        var changes: [TokenBalanceChangeWrapper] = []
        let accountKeys = tx.transaction.message.accountKeys

        for postBalance in postTokenBalances {
            if let preBalance = preTokenBalances.first(where: { $0.accountIndex == postBalance.accountIndex }) {
                let address = postBalance.accountIndex < accountKeys.count ? accountKeys[postBalance.accountIndex] : ""
                let change = TokenBalanceChangeWrapper(
                    address: address,
                    changeType: "transfer",
                    changeAmount: String((Int64(postBalance.uiTokenAmount.amount) ?? 0) - (Int64(preBalance.uiTokenAmount.amount) ?? 0)),
                    decimals: postBalance.uiTokenAmount.decimals,
                    postBalance: postBalance.uiTokenAmount.amount,
                    preBalance: preBalance.uiTokenAmount.amount,
                    tokenAddress: postBalance.mint,
                    owner: postBalance.owner ?? "",
                    postOwner: postBalance.owner ?? "",
                    preOwner: preBalance.owner ?? ""
                )
                changes.append(change)
            }
        }
        return changes.isEmpty ? nil : changes
    }
}

public struct SolBalanceChangeWrapper : Sendable{
    let address: String
    let preBalance: String
    let postBalance: String
    let changeAmount: String

    public init(_ solscanChange: SolBalanceChange) {
        self.address = solscanChange.address
        self.preBalance = solscanChange.pre_balance
        self.postBalance = solscanChange.post_balance
        self.changeAmount = solscanChange.change_amount
    }

    public init(address: String, preBalance: String, postBalance: String, changeAmount: String) {
        self.address = address
        self.preBalance = preBalance
        self.postBalance = postBalance
        self.changeAmount = changeAmount
    }
}

public struct TokenBalanceChangeWrapper : Sendable {
    let address: String
    let changeType: String
    let changeAmount: String
    let decimals: Int
    let postBalance: String
    let preBalance: String
    let tokenAddress: String
    let owner: String
    let postOwner: String
    let preOwner: String

    public init(_ solscanChange: TokenBalanceChange) {
        self.address = solscanChange.address
        self.changeType = solscanChange.change_type
        self.changeAmount = solscanChange.change_amount
        self.decimals = solscanChange.decimals
        self.postBalance = solscanChange.post_balance
        self.preBalance = solscanChange.pre_balance
        self.tokenAddress = solscanChange.token_address
        self.owner = solscanChange.owner
        self.postOwner = solscanChange.post_owner
        self.preOwner = solscanChange.pre_owner
    }

    public init(address: String, changeType: String, changeAmount: String, decimals: Int, postBalance: String, preBalance: String, tokenAddress: String, owner: String, postOwner: String, preOwner: String) {
        self.address = address
        self.changeType = changeType
        self.changeAmount = changeAmount
        self.decimals = decimals
        self.postBalance = postBalance
        self.preBalance = preBalance
        self.tokenAddress = tokenAddress
        self.owner = owner
        self.postOwner = postOwner
        self.preOwner = preOwner
    }
}

public struct ParsedInstructionWrapper : Sendable {
    let type: String
    let program: String
    let programId: String

    public init(_ solscanInstruction: ParsedInstruction) {
        self.type = solscanInstruction.type
        self.program = solscanInstruction.program
        self.programId = solscanInstruction.program_id
    }
}
