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
                  "blockTime": 1757938606,
                  "meta": {
                      "computeUnitsConsumed": 6199,
                      "costUnits": 7861,
                      "err": null,
                      "fee": 5000,
                      "innerInstructions": [],
                      "loadedAddresses": {
                          "readonly": [],
                          "writable": []
                      },
                      "logMessages": [
                          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [1]",
                          "Program log: Instruction: TransferChecked",
                          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 6199 of 200000 compute units",
                          "Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success"
                      ],
                      "postBalances": [
                          85636281,
                          2039280,
                          2039280,
                          418363280639,
                          4676183832
                      ],
                      "postTokenBalances": [
                          {
                              "accountIndex": 1,
                              "mint": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                              "owner": "5SRDAEWJ99aaoTeRyRZSe7zxRicciPd8Np4hb65ZaiKQ",
                              "programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                              "uiTokenAmount": {
                                  "amount": "2000",
                                  "decimals": 6,
                                  "uiAmount": 0.002,
                                  "uiAmountString": "0.002"
                              }
                          },
                          {
                              "accountIndex": 2,
                              "mint": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                              "owner": "H9ca27xrgMhJkCksnD3aZkvjiFE2fMuasFwyHNUNcYaj",
                              "programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                              "uiTokenAmount": {
                                  "amount": "52998000",
                                  "decimals": 6,
                                  "uiAmount": 52.998,
                                  "uiAmountString": "52.998"
                              }
                          }
                      ],
                      "preBalances": [
                          85641281,
                          2039280,
                          2039280,
                          418363280639,
                          4676183832
                      ],
                      "preTokenBalances": [
                          {
                              "accountIndex": 1,
                              "mint": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                              "owner": "5SRDAEWJ99aaoTeRyRZSe7zxRicciPd8Np4hb65ZaiKQ",
                              "programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                              "uiTokenAmount": {
                                  "amount": "1000",
                                  "decimals": 6,
                                  "uiAmount": 0.001,
                                  "uiAmountString": "0.001"
                              }
                          },
                          {
                              "accountIndex": 2,
                              "mint": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                              "owner": "H9ca27xrgMhJkCksnD3aZkvjiFE2fMuasFwyHNUNcYaj",
                              "programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                              "uiTokenAmount": {
                                  "amount": "52999000",
                                  "decimals": 6,
                                  "uiAmount": 52.999,
                                  "uiAmountString": "52.999"
                              }
                          }
                      ],
                      "rewards": [],
                      "status": {
                          "Ok": null
                      }
                  },
                  "slot": 366983068,
                  "transaction": {
                      "message": {
                          "accountKeys": [
                              "H9ca27xrgMhJkCksnD3aZkvjiFE2fMuasFwyHNUNcYaj",
                              "24aGpfvGoWPm8xagsDrsiutbGFs86CrV37QnLLQ3oGYv",
                              "DT4QqJi5q5Znw2wwSfkg4VHsdtZ3H3FzHicZBuTxvpym",
                              "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                              "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
                          ],
                          "header": {
                              "numReadonlySignedAccounts": 0,
                              "numReadonlyUnsignedAccounts": 2,
                              "numRequiredSignatures": 1
                          },
                          "instructions": [
                              {
                                  "accounts": [
                                      2,
                                      3,
                                      1,
                                      0
                                  ],
                                  "data": "j4EYRhtmbmRQq",
                                  "programIdIndex": 4,
                                  "stackHeight": 1
                              }
                          ],
                          "recentBlockhash": "26Kf6AyxkZWY6eSdpJiUdBHzyKoJ938hHv8KYGhdeirn"
                      },
                      "signatures": [
                          "3pyJH9FN53t3231qzUzkKbvLnBwYLWTMwQJG69pNyUcPG8QsZiRaX2ReE3fR23kCwaCTbca7v1wHpV4UDum2AzTg"
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
