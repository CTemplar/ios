import Foundation
import ObjectivePGP

public class PGPService {
    // MARK: Properties
    var keyring = Keyring()
    var keychainService: KeychainService
    
    public init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    public func encodeString(message: String) -> Data {
        return Data(message.utf8)
    }
    
    public func encrypt(data: Data) -> String? {
        if let keys = getStoredPGPKeys() {
            guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else {return ""}
            let encrypted = Armor.armored(encryptedBin, as: .message)
            return encrypted
        }
        return ""
    }
    
    public func encryptAsData(data: Data) -> Data? {
        if let storedKeys = getStoredPGPKeys() {
            return encryptAsData(data: data, keys: storedKeys)
        }
        return nil
    }
    
    public func encryptAsData(data: Data, keys: Array<PGPKey>) -> Data? {
        guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else {return nil}
        return encryptedBin
    }

    public func encrypt(data: Data, keys: Array<PGPKey>) -> String? {
        guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else {return ""}
        let encrypted = Armor.armored(encryptedBin, as: .message)
        return encrypted
    }
    
    public func decrypt(encryptedData: Data) -> Data? {
        let password = keychainService.getPassword()
        if let keys = getStoredPGPKeys() {
            do {
                let decryptedData = try ObjectivePGP.decrypt(encryptedData, andVerifySignature: true, using: keys, passphraseForKey: { (key) -> String? in
                    return password
                })
                return decryptedData
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    public func decodeData(decryptedData: Data) -> String {
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    public func decryptMessage(encryptedContet: String) -> String {
        if let contentData = encryptedContet.data(using: .ascii) {
            if let decodedData = self.decrypt(encryptedData: contentData) {
                let decryptedMessage = self.decodeData(decryptedData: decodedData)
                return decryptedMessage
            } else {
                DPrint("decrypting failed")
                return "#D_FAILED_ERROR#"
            }
        }
        return ""
    }
    
    // MARK: - Keys
    public func generateUserPGPKey(for userName: String, password: String, completion: @escaping Completion<UserPGPKey>) {
        DispatchQueue.global().async {
            let generated = self.generatePGPKey(userName: userName, password: password)
            guard let pub = self.exportArmoredPublicKey(pgpKey: generated),
                let pri = self.exportArmoredPrivateKey(pgpKey: generated),
                let fing = self.fingerprintForKey(pgpKey: generated) else {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.cryptoFailed))
                    }
                    return
            }
            self.savePGPKey(pgpKey: generated)
            DispatchQueue.main.async {
                completion(.success(UserPGPKey(privateKey: pri,
                                               publicKey: pub,
                                               fingerprint: fing)))
            }
        }
    }
    
    public func generatePGPKey(userName: String, password: String) -> PGPKey {
        let generator = KeyGenerator()
        generator.keyBitsLength = 4096
        let pgpKey = generator.generate(for: userName, passphrase: password)
        DPrint("\(generator.keyBitsLength)")
        DPrint("generate keyID:", pgpKey.publicKey?.keyID as Any)
        DPrint("generate fingerprint:", pgpKey.publicKey?.fingerprint as Any)
        return pgpKey
    }
    
    public func exportArmoredPrivateKey(pgpKey: PGPKey) -> String? {
        guard let privateKey = try? pgpKey.export(keyType: .secret) else {return nil}
        let armoredPrivateKey = Armor.armored(privateKey, as: .secretKey)
        DPrint("armoredPrivateKey:", armoredPrivateKey)
        return armoredPrivateKey
    }
    
    public func exportArmoredPublicKey(pgpKey: PGPKey) -> String? {
        guard let publicKey = try? pgpKey.export(keyType: .public) else {return nil}
        let armoredPublicKey = Armor.armored(publicKey, as: .publicKey)
        DPrint("armoredPublicKey:", armoredPublicKey)
        return armoredPublicKey
    }
    
    public func fingerprintForKey(pgpKey: PGPKey) -> String? {
        if let fingerprint = pgpKey.publicKey?.fingerprint.description() {
            return fingerprint
        }
        return nil
    }
    
    public func savePGPKey(pgpKey: PGPKey) {
        keyring.import(keys: [pgpKey])
        let keyRingFileUrl = GeneralConstant.getApplicationSupportDirectoryDirectory().appendingPathComponent(AppSecurity.keyringFileName.rawValue)
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            DPrint("save PGP Key Error")
        }
        DPrint("save PGP Key:", pgpKey)
    }
    
    public func savePGPKeys(pgpKeys: [PGPKey]) {
        keyring.import(keys: pgpKeys)
        let keyRingFileUrl = GeneralConstant.getApplicationSupportDirectoryDirectory().appendingPathComponent(AppSecurity.keyringFileName.rawValue)
        
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            DPrint("save PGP Keys Error")
        }
        DPrint("save PGP Keys:", pgpKeys)
    }
    
    public func getStoredPGPKeys() -> [PGPKey]? {
        let keyRingFileUrl = GeneralConstant.getApplicationSupportDirectoryDirectory().appendingPathComponent(AppSecurity.keyringFileName.rawValue)
        guard let keys = try? ObjectivePGP.readKeys(fromPath: keyRingFileUrl.path) else {return nil}
        return keys
    }
    
    public func readPGPKeysFromString(key : String) -> [PGPKey]? {
        guard let encryptedData = try? Armor.readArmored(key) else {return nil}
        guard let keys = try? ObjectivePGP.readKeys(from: encryptedData) else {return nil}
        DPrint("read keys from string", keys)
        return keys
    }
    
    public func extractAndSavePGPKeyFromString(key: String) {
        if let pgpKeys = self.readPGPKeysFromString(key: key) {
            savePGPKeys(pgpKeys: pgpKeys)
        } else {
            DPrint("can not read keys from string!!!")
        }
    }
    
    public func deleteStoredPGPKeys() {
        keyring.deleteAll()
        let keyRingFileUrl = GeneralConstant.getApplicationSupportDirectoryDirectory().appendingPathComponent(AppSecurity.keyringFileName.rawValue)
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: keyRingFileUrl.path)
        }
        catch let error as NSError {
            DPrint("delete keyring file Error: \(error)")
        }
        DPrint("delete PGP Key")
    }
}
