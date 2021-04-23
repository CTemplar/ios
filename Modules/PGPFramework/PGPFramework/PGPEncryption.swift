
import UIKit
import Gopenpgp
import CryptoKit
//import Networking
typealias KeyRing             = CryptoKeyRing
typealias SplitMessage        = CryptoPGPSplitMessage
typealias PlainMessage        = CryptoPlainMessage
typealias PGPMessage          = CryptoPGPMessage
typealias PGPSignature        = CryptoPGPSignature
typealias AttachmentProcessor = CryptoAttachmentProcessor
typealias SymmetricKey        = CryptoSessionKey


public struct KeysModel: Codable{
    public  var displayName: String?
    public  var email: String?
    public  var fingerprint: String?
    public  var mailboxID: Int?
    public  var isDefault: Bool?
    public  var isEnabled: Bool?
    public  var privateKey: String?
    public  var publicKey: String?
    public  var signature: String?
    public  var keyId = 0
    public  var sortOrder = 0
    public  var isFromPublicKey = false
    
    public init() {}
    
//    mutating func isSaved()-> Bool {
//        if (self.isCompleted == true) {
//            return true
//        }
//        return  false
//    }
}

public class PGPEncryption {
  
    var keysArray:[KeysModel]?
    public init() {}
    
    public func savePrivateAndPublicKeys(key:String) {
        //print(key)
        if (self.keysArray != nil) {
            if let data = try? JSONEncoder().encode(self.keysArray) {
                UserDefaults.standard.set(data, forKey: "keysArray")
                UserDefaults.standard.synchronize()
            }
        }
    }
    // calling function
    func decryptAttachments(encryptedData: Data, key:KeysModel , passcode:String) -> Data? {
        let str = String(data: encryptedData, encoding: String.Encoding.ascii) ?? ""
        // attachment decrypt
        let decryptData = try? decryptAttachment(encrypted: str, privateKey: key.privateKey ?? "", passphrase: passcode)
        if (decryptData == nil) {
            do {
                let data = try decryptAttachment(keyPacket: encryptedData, dataPacket: encryptedData, privateKey: key.privateKey ?? "" , passphrase: passcode)
                
                return data
            }
            catch  (let error) {
                print(error.localizedDescription)
                return nil
            }
        }
        return decryptData
        
    }
    
  public  func decryptImageAttachment(encryptedData: Data, userPassword:String) -> Data? {
        if let data = UserDefaults.standard.value(forKey: "keysArray") as? Data{
            do {
                let dataArray = try? JSONDecoder().decode(Array<KeysModel>.self, from: data)
                if let keysArray = dataArray {
                    for key in keysArray {
//                           let data =  self.decryptAttachments(encryptedData: encryptedData, key: key, passcode: userPassword)
                        let data = try decryptAttach(encrytped:String(data: encryptedData, encoding: String.Encoding.ascii) ?? "", privateKey: key.privateKey ?? "", passphrase: userPassword)
                        if (data != nil) {
                            return data
                        }
                    }
                }
            }
            catch {
                print("error")
            }
            return nil
        }
        return nil
    }
    
    // calling function
   public func decryptSimpleMessage(encrypted:Data, userPassword:String) -> Data? {
        // decrypt Simple message
        

    if let data = UserDefaults.standard.value(forKey: "keysArray") as? Data{
        do {
            let dataArray = try? JSONDecoder().decode(Array<KeysModel>.self, from: data)
            if let keysArray = dataArray {
                for keys in keysArray {
                    do {
                        let decryptedContent = try decrypt(encrytped:String(data: encrypted, encoding: String.Encoding.ascii) ?? "", privateKey: keys.privateKey ?? "", passphrase: userPassword)

                        return Data(decryptedContent.utf8)
                    }
                    catch (let error){
                        print("error")
                    }
                }
            }
        }
        catch {
            print("error")
        }
        return Data()
    }

    return nil
        
    }
    // decrypt attachment file
    
    
     func encryptAttachment(plainData: Data, fileName: String, publicKey: String) throws -> SplitMessage? {
        var error: NSError?
        let key = CryptoNewKeyFromArmored(publicKey, &error)
        if let err = error {
            throw err
        }
        
        let keyRing = CryptoNewKeyRing(key, &error)
        if let err = error {
            throw err
        }
        
        let splitMessage = HelperEncryptAttachment(plainData, fileName, keyRing, &error)//without mutable
        if let err = error {
            throw err
        }
        return splitMessage
    }
    // decrypt simple message
    
    
     func decrypt(encrytped message: String, privateKey: String, passphrase: String) throws -> String {
         var error: NSError?
        //print(privateKey)
        
         let newKey = CryptoNewKeyFromArmored(privateKey, &error)
         if let err = error {
             throw err
         }
         
         guard let key = newKey else {
             return ""
         }
         
         let passSlic = passphrase.data(using: .utf8)
         let unlockedKey = try key.unlock(passSlic)
         
         let privateKeyRing = CryptoNewKeyRing(unlockedKey, &error)
         if let err = error {
             throw err
         }
         
         let pgpMsg = CryptoNewPGPMessageFromArmored(message, &error)
         if let err = error {
             throw err
         }
        
       
        let plainMessageString = try privateKeyRing?.decrypt(pgpMsg, verifyKey: nil, verifyTime: 0).getString() ?? ""
         return plainMessageString
     }
    
    func decryptAttach(encrytped message: String, privateKey: String, passphrase: String) throws -> Data? {
        var error: NSError?
       //print(privateKey)
       
        let newKey = CryptoNewKeyFromArmored(privateKey, &error)
        if let err = error {
            throw err
        }
        
        guard let key = newKey else {
            return nil
        }
        
        let passSlic = passphrase.data(using: .utf8)
        let unlockedKey = try key.unlock(passSlic)
        
        let privateKeyRing = CryptoNewKeyRing(unlockedKey, &error)
        if let err = error {
            throw err
        }
        
        let pgpMsg = CryptoNewPGPMessageFromArmored(message, &error)
        if let err = error {
            throw err
        }
       
      
       let plainMessageString = try privateKeyRing?.decrypt(pgpMsg, verifyKey: nil, verifyTime: 0).getBinary() ?? nil
        return plainMessageString
    }

    
    
     func decryptAttachment(encrypted: String, privateKey: String, passphrase: String) throws -> Data? {
        var error: NSError?
        let key = CryptoNewKeyFromArmored(privateKey, &error)
        if let err = error {
            throw err
        }
        
        let passSlic = passphrase.data(using: .utf8)
        let unlockedKey = try key?.unlock(passSlic)
        let keyRing = CryptoNewKeyRing(unlockedKey, &error)
        if let err = error {
            throw err
        }
        
        let splitMessage = CryptoNewPGPSplitMessageFromArmored(encrypted, &error)
        if let err = error {
            throw err
        }
        do {
            let plainMessage = try  keyRing?.decryptAttachment(splitMessage)
            return plainMessage?.getBinary()
        }
        catch (let error) {
            print(error.localizedDescription)
            return nil
        }
       
    }
    
    // decrypt attachment second methods
    
    func decryptAttachment(keyPacket: Data, dataPacket: Data, privateKey: String, passphrase: String) throws -> Data? {
        var error: NSError?
        let key = CryptoNewKeyFromArmored(privateKey, &error)
        if let err = error {
            throw err
        }
        
        let passSlic = passphrase.data(using: .utf8)
        let unlockedKey = try key?.unlock(passSlic)
        let keyRing = CryptoNewKeyRing(unlockedKey, &error)
        if let err = error {
            throw err
        }
        
        let splitMessage = CryptoNewPGPSplitMessage(keyPacket as Data, dataPacket as Data)
        do {
        let plainMessage = try keyRing?.decryptAttachment(splitMessage)
            return plainMessage?.getBinary()
        }
        catch (let error) {
                print(error.localizedDescription)
            return nil
        }
       
    }
    
     func decryptAttachment1(splitMessage: SplitMessage, privateKey: String, passphrase: String) throws -> Data? {
        var error: NSError?
        let key = CryptoNewKeyFromArmored(privateKey, &error)
        if let err = error {
            throw err
        }
        
        let passSlic = passphrase.data(using: .utf8)
        let unlockedKey = try key?.unlock(passSlic)
        let keyRing = CryptoNewKeyRing(unlockedKey, &error)
        if let err = error {
            throw err
        }
        
        let plainMessage = try keyRing?.decryptAttachment(splitMessage)
        return plainMessage?.getBinary()
    }
    
    public func generateNewKeyModel(userName: String, password: String) -> KeysModel {
        let err:NSErrorPointer = NSErrorPointer(nilLiteral: ())
        var email = ""
        var name = ""
        if let dataArray = userName.components(separatedBy: "@") as? Array<String>, dataArray.count > 1  {
            name = dataArray[0]
            if (dataArray[1] == "ctemplar.com") {
                email = name + "@ctemplar.com"
            }
            else {
               email = userName
            }
        }
        else {
            name = userName
            email = userName + "@ctemplar.com"
        }
        
        let privatePGPKey = HelperGenerateKey(name, email, Data(password.utf8), "x25519", 0, err)
        let key = CryptoNewKeyFromArmored(privatePGPKey, err)
        let publicPGPKey =  key?.getArmoredPublicKey(err)
        var keyModel = KeysModel()
        keyModel.email = userName
        keyModel.isEnabled = true
        keyModel.privateKey = privatePGPKey
        keyModel.publicKey = publicPGPKey
        keyModel.fingerprint = key?.getFingerprint()
        keyModel.isFromPublicKey = true
        
        return keyModel
    }
    
    
//    func generateFreshKeys(){
//
//        // Account A
//
//        let passpharseOne = Data(passwordOne.utf8)
//        let privatePGPKeyFirstAccount = HelperGenerateKey(NameOne, mailIDOne, passpharseOne, "x25519", 0, err)
//        let key = CryptoNewKeyFromArmored(privatePGPKeyFirstAccount, err)
//        let publicPGPKeyFirstAccount =  key?.getArmoredPublicKey(err)
//        print(publicPGPKeyFirstAccount as Any)
//        print(privatePGPKeyFirstAccount as Any)
//
//
//        // Account B
//
//        // account second keys Generation
//
//        let passpharseTwo = Data(passwordTwo.utf8)
//        let privatePGPKeySecondAccount = HelperGenerateKey(NameTwo, mailIDTwo, passpharseTwo, "x25519", 0, err)
//        let key1 = CryptoNewKeyFromArmored(privatePGPKeySecondAccount, err)
//        let publicPGPKeySecondAccount =  key1?.getArmoredPublicKey(err)
//
//        print(publicPGPKeySecondAccount as Any)
//        print(privatePGPKeySecondAccount as Any)
//
//
//
//        // now encryption decryption mechnism with Simple Message
//
//        let encryptedMessage = HelperEncryptMessageArmored(publicPGPKeyFirstAccount, message, err)
//        print(encryptedMessage)
//        let decryptMessage = HelperDecryptMessageArmored(privatePGPKeyFirstAccount, passpharseOne, encryptedMessage, err)
//        print(decryptMessage)
//
//
//
//
//
//
//     //   encryption decryption mechnism with Attachments file
//
//
//        // convert image to Data Format
//
//
//        let profileImage = UIImage(named:"101-Questions-New")!
//        let imageData = profileImage.pngData()
//
//        let encryptAttachmentFile =  try? encryptAttachment(plainData: imageData!, fileName: "101-Questions-New.png", publicKey: publicPGPKeySecondAccount!)
//
//        print(encryptAttachmentFile)
//
//
//
//        //decrypt attachment file
//
//        let decryptAttachmentFile = try? decryptAttachment1(splitMessage: encryptAttachmentFile!, privateKey: privatePGPKeySecondAccount, passphrase: passwordTwo)
//
//
//        print(decryptAttachmentFile)
//
//        let generatedImage : UIImage = UIImage(data: decryptAttachmentFile!)!
//        print(generatedImage)
//        imageView.image = generatedImage
//
//
//    }
    
    
    
    
    
    
    
//    func generateKey()
//    {
//
//
//        // image as data
//
//        let url = URL(string: attachmentOlderURL)
//        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check /
//
//        print(data)
//
//
//
//        let passpharse = Data(password.utf8)
//
//        let dataPacket = Data(attachmentOlderURL.utf8)
//
//
//
//        let privatePGPKey = HelperGenerateKey(name, mailID, passpharse, "x25519", 0, err)
//
//
//        print(privatePGPKey)
//
//        let key = CryptoNewKeyFromArmored(privatePGPKey, err)
//        let nwPubKey =  try! key?.getPublicKey()
//
//
//        let publicPGPKey =  key?.getArmoredPublicKey(err)
//
//        print(publicPGPKey as Any)
//
//        print(publicPGPKey as Any)
//
//        let ring = CryptoKeyRing(key)
//
//
//        let encryptedMessage = HelperEncryptMessageArmored(publicPGPKey, message, err)
//
//        print(encryptedMessage)
//
//
//
//        let decryptedMessage1 = HelperDecryptMessageArmored(privatePGPKey, passpharse, encryptedMessage, err)
//
//
//        print(decryptedMessage1)
//
//
//        let decryptedMessage = HelperDecryptMessageArmored(olderPrivateKey, passpharse, messageEncry, err)
//
//        print(decryptedMessage)
//
//
//
//
//
//
//        //   new methods encrypt and decrypt attachments
//
//        let profileImage = UIImage(named:"101-Questions-New")!
//        let imageData = profileImage.pngData()
//
//        let encryptAttachment = HelperEncryptAttachmentWithKey(publicPGPKey, "101-Questions-New.png", imageData, err)
//
//
//        // new methods convert attachment into data format
//
//        print(encryptAttachment)
//
//
//
//        let decryptedAttachment =  HelperDecryptAttachmentWithKey(privatePGPKey, passpharse, encryptAttachment?.keyPacket, encryptAttachment?.dataPacket, err)
//
//        print(decryptedAttachment)
//
//        let image : UIImage = UIImage(data: decryptedAttachment!)!
//
//        print(image)
//
//
//        imageView.image = image
//
////        let imageDataFile:CryptoPGPSplitMessage = dataPacket
//
//
////        let profileImage1 = UIImage(contentsOfFile: attachmentOlderURL)!
////        let imageData2 = profileImage1.pngData()
//
//      // decrypt older attachments
//
////        let decrytOlderAttachments  = HelperDecryptAttachmentWithKey(olderPrivateKey, passpharse, dataPacket, <#T##dataPacket: Data?##Data?#>, <#T##error: NSErrorPointer##NSErrorPointer#>)
////
//
//
//
////        let encryptmsg =  try! ring?.encrypt(CryptoPlainMessage(from: message), privateKey: ring)
////        print(encryptmsg as Any)
////
////
////        let decMsg = try! ring?.decrypt(encryptmsg, verifyKey: ring, verifyTime: 0)
////        print(decMsg as Any)
//    }
    
//    func tey() {
   // let err:NSErrorPointer = NSErrorPointer(nilLiteral: ())
//        let publicKey = "E225AABFFE9901B9"
//        let privateKey = "E225AABFFE9901B9"
//        let passPharse = mailID
//        let pbKey = CryptoNewKeyFromArmored(publicKey, err)
//        let pvkey = CryptoNewKeyFromArmored(privateKey, err)
//        let pvunRing = try! pvkey?.unlock(Data(base64Encoded: passPharse))
//        let pbRing = CryptoKeyRing(pbKey)
//        let pvRing = CryptoKeyRing(pvkey)
//        let messageEncrypted = try! pbRing?.encrypt(CryptoPlainMessage(from: message), privateKey: pvRing)
//       
//        
//    }
    
    
    public func encryptMessage(keys:Array<KeysModel>, data:Data)-> String {
        let err:NSErrorPointer = NSErrorPointer(nilLiteral: ())
        let keyring = CryptoNewKeyRing(nil, err)
        for key in keys {
            let pbKey = CryptoNewKeyFromArmored(key.publicKey, err)
            try? keyring?.add(pbKey)
        }
        let message = CryptoPlainMessage(data)
        
        let encryptedMessage = try? keyring?.encrypt(message, privateKey: nil)
        if (encryptedMessage == nil) {
            return ""
        }
        else {
            let encryptedString =  encryptedMessage?.getArmored(err)
            if (encryptedString == nil) {
                return ""
            }
            return encryptedString!
        }
    }

    public func encryptAttachment(keys:Array<KeysModel>, data:Data, fileName:String)-> String {
        let err:NSErrorPointer = NSErrorPointer(nilLiteral: ())
        let keyring = CryptoNewKeyRing(nil, err)
        for key in keys {
            let pbKey = CryptoNewKeyFromArmored(key.publicKey, err)
            try? keyring?.add(pbKey)
            print(String(keyring?.countEntities() ?? 0))
        }
        let message = CryptoPlainMessage(data)
        
        let encryptedMessage = try? keyring?.encryptAttachment(message, filename: fileName)
        if (encryptedMessage == nil) {
            return ""
        }
        else {
            let encryptedString =  encryptedMessage?.getArmored(err)
            if (encryptedString == nil) {
                return ""
            }
            return encryptedString!
        }
    }
    
}

extension String {
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
