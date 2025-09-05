import Testing
import Foundation
@testable import SolanaKit

@Test func testAll() async throws {
    try await testGetBalance()
    try await testGetTransaction()
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
