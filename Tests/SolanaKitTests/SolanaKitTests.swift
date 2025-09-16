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
    let client = SolanaHttpsClient(baseURL: "https://api.mainnet-beta.solana.com")
    let solscanClient = SolscanHttpsClient(apiKey: Config.solscanApiKey)
    
    let expectedJSON = MockData.TransactionJsonResponse
    
    let expectedTransaction = try JSONDecoder().decode(SolanaRPCResponse<GetTransactionResult>.self, from: expectedJSON.data(using: .utf8)!)
    
    let expectedTransactionObj : SolanaTransactionWrapper
    
    switch expectedTransaction {
    case .success(jsonrpc: _, result: let result, id: _):
        expectedTransactionObj = SolanaTransactionWrapper(result, txHash: "3pyJH9FN53t3231qzUzkKbvLnBwYLWTMwQJG69pNyUcPG8QsZiRaX2ReE3fR23kCwaCTbca7v1wHpV4UDum2AzTg")
    case .error(jsonrpc: _, error: _, id: _):
        #expect(Bool(false)) // should never happen
        return
    }
    
    let rpcTransaction = try await client.getTransactionDetails(signature: "3pyJH9FN53t3231qzUzkKbvLnBwYLWTMwQJG69pNyUcPG8QsZiRaX2ReE3fR23kCwaCTbca7v1wHpV4UDum2AzTg")
    
    let solscanTransaction = try await solscanClient.getTransactionDetail(signature: "3pyJH9FN53t3231qzUzkKbvLnBwYLWTMwQJG69pNyUcPG8QsZiRaX2ReE3fR23kCwaCTbca7v1wHpV4UDum2AzTg")
    
    #expect(rpcTransaction?.txHash == solscanTransaction?.txHash && rpcTransaction?.txHash == expectedTransactionObj.txHash)
    #expect(rpcTransaction?.signers == solscanTransaction?.signers && rpcTransaction?.signers == expectedTransactionObj.signers)
}

@Test func testGetFalseTransaction() async throws {
    print("testGetFalseTransaction started...")
    let client = SolanaHttpsClient()
    let transaction = try await client.getTransactionDetails(signature: "false_signature")
    
}

@Test func testGetBalance() async throws {
    print("testGetBalance started...")
    let client = SolanaHttpsClient()
    let address = "H9ca27xrgMhJkCksnD3aZkvjiFE2fMuasFwyHNUNcYaj"
    let balance = try await client.getAccountDetails(address: address)
    
    let expectedJSON = MockData.BalanceJsonResponse
    
    let expectedBalance = try JSONDecoder().decode(SolanaRPCResponse<GetBalanceResult>.self, from: expectedJSON.data(using: .utf8)!)
    
    #expect(balance != nil)
    print(balance?.rent_epoch)
//
//    switch (balance, expectedBalance) {
//    case (.success(let jsonrpc, let result, let id), .success(let expectedJsonrpc, let expectedResult, let expectedId)):
//        // Asserting SolanaRPCResponse
//        #expect(jsonrpc == expectedJsonrpc)
//        #expect(id == expectedId)
//        
//        // Asserting GetBalanceResult
//        #expect(result.value == expectedResult.value)
//    case (.error(_, let error, _), _):
//        #expect(Bool(false), "Expected success but got error: \(error.message)")
//    case (_, .error(_, let expectedError, _)):
//        #expect(Bool(false), "Expected balance should be success but got error: \(expectedError.message)")
//    }
}

@Test func testGetSignaturesForAddress() async throws {
    print("testGetSignaturesForAddress started...")
    let client = SolanaHttpsClient()
    let signatures = try await client.getTransactions(
        forAddress: "83astBRguLMdt2h5U1Tpdq5tjFoJ6noeGwaY3mDLVcri",
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

@Test func testSolScanGetAccount() async throws {
    let address = "H9ca27xrgMhJkCksnD3aZkvjiFE2fMuasFwyHNUNcYaj"
    
    let client = SolscanHttpsClient(apiKey: Config.solscanApiKey)
    let account = try await client.getAccountDetails(address: address)
    print("18446744073709552000" < "18446744073709551615")
    #expect(account != nil)
}

