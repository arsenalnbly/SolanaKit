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
    
    switch (transaction, expectedTransaction) {
    case (.success(let jsonrpc, let result, let id), .success(let expectedJsonrpc, let expectedResult, let expectedId)):
        // Asserting SolanaTransactionResponse
        #expect(jsonrpc == expectedJsonrpc)
        #expect(id == expectedId)
        
        // Asserting TransactionResult
        #expect(result.blockTime == expectedResult.blockTime)
        #expect(result.slot == expectedResult.slot)
        #expect(result.version == expectedResult.version)
    case (.error(_, let error, _), _):
        #expect(Bool(false), "Expected success but got error: \(error.message)")
    case (_, .error(_, let expectedError, _)):
        #expect(Bool(false), "Expected transaction should be success but got error: \(expectedError.message)")
    }
}

@Test func testGetFalseTransaction() async throws {
    print("testGetFalseTransaction started...")
    let client = SolanaHttpsClient()
    let transaction = try await client.getTransaction(signature: "false_signature")
    
    switch transaction {
    case .success(_, _, _):
        #expect(Bool(false), "Expected error but got success")
    case .error(_, let error, _):
        print(error.message)
        #expect(error.code != 0 || !error.message.isEmpty)
    }
}

@Test func testGetBalance() async throws {
    print("testGetBalance started...")
    let client = SolanaHttpsClient()
    let balance = try await client.getBalance(pubkey: "83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri")
    
    let expectedJSON = MockData.BalanceJsonResponse
    
    let expectedBalance = try JSONDecoder().decode(SolanaRPCResponse<GetBalanceResult>.self, from: expectedJSON.data(using: .utf8)!)
    
    switch (balance, expectedBalance) {
    case (.success(let jsonrpc, let result, let id), .success(let expectedJsonrpc, let expectedResult, let expectedId)):
        // Asserting SolanaRPCResponse
        #expect(jsonrpc == expectedJsonrpc)
        #expect(id == expectedId)
        
        // Asserting GetBalanceResult
        #expect(result.value == expectedResult.value)
    case (.error(_, let error, _), _):
        #expect(Bool(false), "Expected success but got error: \(error.message)")
    case (_, .error(_, let expectedError, _)):
        #expect(Bool(false), "Expected balance should be success but got error: \(expectedError.message)")
    }
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
    
    switch (signatures, expectedSignatures) {
    case (.success(let jsonrpc, let result, let id), .success(let expectedJsonrpc, let expectedResult, let expectedId)):
        // Asserting SolanaRPCResponse
        #expect(jsonrpc == expectedJsonrpc)
        #expect(id == expectedId)
        
        // Asserting [SolanaSignature] result
        #expect(result.count == expectedResult.count)
        
        for i in 0..<result.count {
            let signature = result[i]
            let expectedSignature = expectedResult[i]
            #expect(signature.signature == expectedSignature.signature)
            #expect(signature.slot == expectedSignature.slot)
            #expect(signature.blockTime == expectedSignature.blockTime)
        }
    case (.error(_, let error, _), _):
        #expect(Bool(false), "Expected success but got error: \(error.message)")
    case (_, .error(_, let expectedError, _)):
        #expect(Bool(false), "Expected signatures should be success but got error: \(expectedError.message)")
    }
}

@Test func testPublicSolscan() async throws {
    let client = SolscanHttpsClient(baseURL: "https://public-api.solscan.io")
    let chainInfo = try await client.getChainInfo()
    switch chainInfo {
    case .success(success: let success, data: let data):
        #expect(true)
    case .error(success: let success, errors: let errors):
        #expect(Bool(false))
    }
}
