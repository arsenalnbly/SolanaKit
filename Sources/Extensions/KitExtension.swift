import Solana

public extension Kit {
    static func validate(address: String) throws {
        guard let _ = PublicKey(string: address) else {
            throw PublicKey.PublicKeyError.invalidPublicKey
        }
    }
}

