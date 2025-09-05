import Testing
import Foundation
@testable import SolanaKit

@Test func testAll() async throws {
    try await testGetBalance()
    try await testGetTransaction()
    try await testGetFalseTransaction()
    try await testGetSignaturesForAddress()
}

@Test func testGetTransaction() async throws {
    print("testGetTransatcion started... ")
    let client = SolanaHttpsClient()
    let transaction = try await client.getTransaction(signature: "5Pj5fCupXLUePYn18JkY8SrRaWFiUctuDTRwvUy2ML9yvkENLb1QMYbcBGcBXRrSVDjp7RjUwk9a3rLC6gpvtYpZ")
    
    let expectedJSON = MockData.TransactionJsonResponse
    
    let expectedTransaction = try JSONDecoder().decode(SolanaRPCResponse<GetTransactionResult>.self, from: expectedJSON.data(using: .utf8)!)
    
    // Asserting SolanaTransactionResponse
    #expect(transaction.jsonrpc == expectedTransaction.jsonrpc)
    #expect(transaction.id == expectedTransaction.id)
    
    // Asserting TransactionResult
    let result = transaction.result
    let expectedResult = expectedTransaction.result
    #expect(result?.blockTime == expectedResult?.blockTime)
    #expect(result?.slot == expectedResult?.slot)
    #expect(result?.version == expectedResult?.version)
    
}

@Test func testGetFalseTransaction() async throws {
    print("testGetFalseTransaction started...")
    let client = SolanaHttpsClient()
    let transaction = try await client.getTransaction(signature: "false_signature")
    #expect(transaction.error != nil)
    print(transaction.error?.message)
}

@Test func testGetBalance() async throws {
    print("testGetBalance started...")
    let client = SolanaHttpsClient()
    let balance = try await client.getBalance(pubkey: "83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri")
    
    let expectedJSON = MockData.BalanceJsonResponse
    
    let expectedBalance = try JSONDecoder().decode(SolanaRPCResponse<GetBalanceResult>.self, from: expectedJSON.data(using: .utf8)!)
    
    // Asserting SolanaRPCResponse
    #expect(balance.jsonrpc == expectedBalance.jsonrpc)
    #expect(balance.id == expectedBalance.id)
    
    // Asserting GetBalanceResult
    let result = balance.result
    let expectedResult = expectedBalance.result
    #expect(result?.value == expectedResult?.value)
}

@Test func testGetSignaturesForAddress() async throws {
    print("testGetSignaturesForAddress started...")
    let client = SolanaHttpsClient()
    let signatures = try await client.getSignaturesForAddress(
        address: "83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri",
        commitment: "finalized",
        minContextSlot: nil,
        limit: 10,
        before: nil,
        until: nil
    )
    
    let expectedJSON = MockData.SignaturesForAddressJsonResponse
    
    let expectedSignatures = try JSONDecoder().decode(SolanaRPCResponse<[SolanaSignature]>.self, from: expectedJSON.data(using: .utf8)!)
    
    // Asserting SolanaRPCResponse
    #expect(signatures.jsonrpc == expectedSignatures.jsonrpc)
    #expect(signatures.id == expectedSignatures.id)
    
    // Asserting [SolanaSignature] result
    let result = signatures.result
    let expectedResult = expectedSignatures.result
    #expect(result?.count == expectedResult?.count)
    
    for i in 0..<result!.count {
        if let signature = result?[i], let expectedSignature = expectedSignatures.result?[i] {
            #expect(signature.signature == expectedSignature.signature)
            #expect(signature.slot == expectedSignature.slot)
            #expect(signature.blockTime == expectedSignature.blockTime)
        }
    }
}
