//
//  MockData.swift
//  SolanaKit
//
//  Created by arsenal on 05.09.25.
//

import Foundation

struct MockData {
    static let TransactionJsonResponse =  """
          {
              "jsonrpc": "2.0",
              "result": {
                  "blockTime": 1746479684,
                  "meta": {
                      "computeUnitsConsumed": 150,
                      "err": null,
                      "fee": 5000,
                      "innerInstructions": [],
                      "loadedAddresses": {
                          "readonly": [],
                          "writable": []
                      },
                      "logMessages": [
                          "Program 11111111111111111111111111111111 invoke [1]",
                          "Program 11111111111111111111111111111111 success"
                      ],
                      "postBalances": [989995000, 10000000, 1],
                      "postTokenBalances": [],
                      "preBalances": [1000000000, 0, 1],
                      "preTokenBalances": [],
                      "rewards": [],
                      "status": {
                          "Ok": null
                      }
                  },
                  "slot": 378917547,
                  "transaction": {
                      "message": {
                          "accountKeys": [
                              "7BvfixZx7Rwywf6EJFgRW6acEQ2FLSFJr4n3kLLVeEes",
                              "6KtbxYovphtE3eHjPjr2sWwDfgaDwtAn2FcojDyzZWT6",
                              "11111111111111111111111111111111"
                          ],
                          "header": {
                              "numReadonlySignedAccounts": 0,
                              "numReadonlyUnsignedAccounts": 1,
                              "numRequiredSignatures": 1
                          },
                          "instructions": [
                              {
                                  "accounts": [0, 1],
                                  "data": "3Bxs4NN8M2Yn4TLb",
                                  "programIdIndex": 2,
                                  "stackHeight": 1
                              }
                          ],
                          "recentBlockhash": "23dwTHxFhSzqohXhdni5LwpuSRpgN36YvVMCAM2VXQSf"
                      },
                      "signatures": [
                          "5Pj5fCupXLUePYn18JkY8SrRaWFiUctuDTRwvUy2ML9yvkENLb1QMYbcBGcBXRrSVDjp7RjUwk9a3rLC6gpvtYpZ"
                      ]
                  },
                  "version": "legacy"
              },
              "id": 1
          }
          """
    
    static let BalanceJsonResponse = """
        {"jsonrpc":"2.0","result":{"context":{"apiVersion":"2.3.6","slot":405819028},"value":1362524722001},"id":1}
        """
    
    static let SignaturesForAddressJsonResponse = """
        {"jsonrpc":"2.0","result":[{"blockTime":1756984005,"confirmationStatus":"finalized","err":null,"memo":null,"signature":"pEPu4fKF5cR286LHNJ7RLMbRY9rBxX1KS6fk7EZcor4RnFssq432hveXLgcRrhVfQpTjNbbjsDDCA6YGXsrxNKQ","slot":405577592},{"blockTime":1756363997,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"3GbzJVUMm34Bi4S4PiEiKM18bdxu9kMVpxxedvvrgUorHv59KaqjEJe8KGUr2F54pd1Bz1tLnFAVYWrvf4LC7Tmm","slot":404057651},{"blockTime":1756362000,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"2kaA11hejhFhXBTU8XmYNhePMrs9u5nAARUpVBLcLuydA1TTTPrfWZ5hidsUct8F8phzExZk1mK2CL8WbSW5Usr9","slot":404052710},{"blockTime":1756360185,"confirmationStatus":"finalized","err":null,"memo":null,"signature":"4HjEpKxg1sTMNZx8vy4xofKLM52ZpppP1HgUpfPNQ1nFQDuXjS3jGywUfTA3dShh3hNd4zfVwZ8F9Gy2r2FJb9mA","slot":404048217},{"blockTime":1756352020,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"1KBi3vQ5NfzL821BfgBedw9KkpvXKrqVt3zMdeRAR8njbAwTjcmtutnvE5xrjssfxUXuKRBECMAUS6VfQH7ZmMj","slot":404028009},{"blockTime":1756349510,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"4NodFJaqdspMYfrEpMJugJ81oaUBHCvok8HUnoCLMqSfeTHc6AG4at5YLiYs29WgoeHzzA52q7N1HJhGwjNcrtZX","slot":404021777},{"blockTime":1756346829,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"2JJnnWmJSewRCMEkF9pLSZBaAJWKMpqsbwRW1tcSsPSaD5CSTmjdEVF2kkcs5Ga5MeTJSFzsq9j7RJ5NPdoVA2EJ","slot":404015151},{"blockTime":1756345870,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"2vBbC5ko4hbFS5d65ai8Df7KkxatDUkT1GbpFYkDQwHEVjjqxK6dZQXgjzCjzfKn197F9oLqzyHCfQTUGNEVPLhz","slot":404012772},{"blockTime":1756292458,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"4cDonyHgz7iM8bFm3BpkPHwcUi6sQ8RoZeoV46H1aJ3yYeMhUFfnRv8pvd5QU1TGRaVBmyoAmWxFBUSrJgBckDbv","slot":403880576},{"blockTime":1756292085,"confirmationStatus":"finalized","err":{"InstructionError":[0,{"Custom":1}]},"memo":null,"signature":"4mvjPhJo7XxabZMGawUJhrBr1qUKtgGfDV9Gv7p9DwFPsk7NvZ7dFnE3mtnjNFDYBAbBeaU5kVGZzWSCHp3rpL5G","slot":403879656}],"id":1}
        """
}
