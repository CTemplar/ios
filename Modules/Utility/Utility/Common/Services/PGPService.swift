import Foundation
import ObjectivePGP
import PGPFramework

public class PGPService {
    // MARK: Properties
    var keyring = Keyring()
    var keychainService: KeychainService
    var encryptionObj:PGPEncryption = PGPEncryption()
    
    public init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    public func encodeString(message: String) -> Data {
        return Data(message.utf8)
    }
    
    public func encrypt(data: Data) -> String? {
        if let keys = getStoredPGPKeys() {
            guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else { return "" }
            let encrypted = Armor.armored(encryptedBin, as: .message)
            return encrypted
        }
        return ""
    }
    
    public func encryptAttachment(data: Data) -> Data? {
        guard let keys = getStoredPGPKeys() else {
            return nil
        }
        
        guard let encryptedString = encrypt(data: data, keys: keys) else {
            return nil
        }
        
        return encodeString(message: encryptedString)
    }
    
    public func encryptAsData(data: Data) -> Data? {
        if let storedKeys = getStoredKeysModel() {
            return encryptAsData(data: data, keys: storedKeys)
        }
        return nil
    }
    
    public func encryptAsData(data: Data, keys: Array<KeysModel>) -> Data? {
        let encryptedString = self.encryptionObj.encryptMessage(keys: keys, data: data)
        return encodeString(message: encryptedString)
    }
    
    public func encrypt(data: Data, keys: Array<PGPKey>) -> String? {
        guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else { return "" }
        let encrypted = Armor.armored(encryptedBin, as: .message)
        return encrypted
    }
    
    public func encryptAsDataWithKeyModel(data: Data, keys: Array<KeysModel>, fileName:String) -> Data? {
       // let encryptedString = self.encryptionObj.encryptAttachment(keys: keys, data: data, fileName: fileName)
        let encryptedString = self.encryptionObj.encryptMessage(keys: keys, data: data)
        return encodeString(message: encryptedString)
    }
    

    public func encryptWithKeyModel(data: Data, keys: Array<KeysModel>) -> String? {
        return self.encryptionObj.encryptMessage(keys: keys, data: data)
    }
    
    public func encryptWithFromPassword(data: String, password:String) -> String? {
        do {
            return try self.encryptionObj.encrypt(plainText: data, token: password)
        }
        catch {
            return nil
        }
    }
    
    public func decrypt(encryptedData: Data) -> Data? {
        let password = keychainService.getPassword()
        if let data =  self.encryptionObj.decryptSimpleMessage(encrypted: encryptedData, userPassword: password) {
            return data
        }
//        return Data()
//        if let keys = getStoredPGPKeys() {
//            print(keys)
//            do {
//                let decryptedData = try ObjectivePGP.decrypt(encryptedData,
//                                                             andVerifySignature: true,
//                                                             using: keys,
//                                                             passphraseForKey: { (key) -> String? in
//                                                                return password
//                })
//
//
//
//                return decryptedData
//            } catch {
//                DPrint(error.localizedDescription)
//            }
//        }
        
        return nil
    }
    
    public func decryptImageAttachment(encryptedData: Data) -> Data? {
        let password = keychainService.getPassword()
        if let data =  self.encryptionObj.decryptImageAttachment(encryptedData: encryptedData, userPassword: password) {
            return data
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
    
    
    public func decryptMessageFromPassword(encryptedContent: String, password:String) -> String {
        do {
            if let decryptedMessage = try self.encryptionObj.decryptFromPassword(encrypted: encryptedContent, token: password) {
                return decryptedMessage
            } else {
                DPrint("decrypting failed")
                return "#D_FAILED_ERROR#"
            }
        }
        catch {
            DPrint("decrypting failed")
            return "#D_FAILED_ERROR#"
        }
    }
    
    public func decryptMessageFromInbox(encryptedContet: String) -> String {
        if let contentData = encryptedContet.data(using: .ascii) {
            let password = keychainService.getPassword()
            if let data =  PGPEncryption().decryptSimpleMessage(encrypted: contentData, userPassword: password) {
                let decryptedMessage = self.decodeData(decryptedData: data)
                return decryptedMessage
                
            }
            else {
                DPrint("decrypting failed")
                return "#D_FAILED_ERROR#"
            }
        }
        return ""
    }
    
    // MARK: - Keys
    public func generateUserPGPKey(for userName: String, password: String, completion: @escaping Completion<UserPGPKey>) {
        DispatchQueue.global().async {
            let generator  = self.encryptionObj.generateNewKeyModel(userName: userName, password: password) as KeysModel
           // let generated = self.generatePGPKey(userName: userName, password: password)
            
            guard let pub = generator.publicKey,
                  let pri = generator.privateKey,
                let fing = generator.fingerprint else {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.cryptoFailed))
                    }
                    return
            }
           // self.savePGPKey(pgpKey: generated)
            var array = Array<KeysModel>()
            array.append(generator)
            if let data = try? JSONEncoder().encode(array) {
                    UserDefaults.standard.set(data, forKey: "keysArray")
                    UserDefaults.standard.synchronize()
            }
 
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
    
    public func getPasswordFromKeychain() -> String {
       return keychainService.getPassword()

    }
    public func generateNewKeyModel(userName: String, password: String) -> KeysModel? {
        return self.encryptionObj.generateNewKeyModel(userName: userName, password: password)
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

//        do {
//            let data = try keys[0].publicKey?.export()
//            if (Armor.isArmoredData(data!) == true) {
//                let newdata = try Armor.armored(data!, as: PGPArmorType(rawValue: keys[0].publicKey?.type.rawValue ?? 0)!)
//                print(newdata)
//            }
//
//            print(String(decoding:  data!, as: UTF8.self))
//
//        } catch {
//                print("The file could not be loaded")
//        }

        return keys
    }
    
    public func getStoredKeysModel() -> [KeysModel]? {
        if let data = UserDefaults.standard.value(forKey: "keysArray") as? Data{
            let dataArray = try? JSONDecoder().decode(Array<KeysModel>.self, from: data)
            return dataArray
        }
        return nil
    }

    
    public func readPGPKeysFromString(key : String) -> [PGPKey]? {
        guard let encryptedData = try? Armor.readArmored(key) else {return nil}
        guard let keys = try? ObjectivePGP.readKeys(from: encryptedData) else {return nil}
        DPrint("read keys from string", keys)
        return keys
    }
    
    public func extractAndSavePGPKeyFromString(key: String) {
       // print(key)
        //self.encryptionObj.savePrivateAndPublicKeys(key: key)
       if let pgpKeys = self.readPGPKeysFromString(key: key) {
            savePGPKeys(pgpKeys: pgpKeys)
        } else {
            DPrint("can not read keys from string!!!")
        }
    }
    
    public func deleteStoredPGPKeys() {
        UserDefaults.standard.setValue(nil, forKey: "keysArray")
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
