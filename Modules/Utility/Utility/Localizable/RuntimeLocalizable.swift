import Foundation

public protocol Localizable {
  var localized: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  public var localized: String {
    let bundle = Bundle(for: RuntimeLocalizable.self)
    
    if let path = bundle.path(forResource: Bundle.getLanguage(), ofType: "lproj"),
        let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: self.rawValue,
                                       value: self.rawValue,
                                       table: RuntimeLocalizable.tableName)
    } else {
         return NSLocalizedString(self.rawValue,
                                  tableName: RuntimeLocalizable.tableName,
                                  bundle: RuntimeLocalizable.shared.localizedBundle ?? Bundle(for: RuntimeLocalizable.self),
                                  comment: ""
        )
    }
  }
}

public final class RuntimeLocalizable {
  // Singleton
  static let shared = RuntimeLocalizable()
  
  // Typealias
  public typealias LanguageKey = String
  public typealias Language = Dictionary<String, String>
  public typealias Translations = Dictionary<LanguageKey, Language>
  
  static let tableName: String = "Localizable" // Should be same name as the strings file
  static let bundleName = "RuntimeLocalizable.bundle"
  
  lazy public var localizedBundle: Bundle? = { Bundle(url: bundlePath) }()
  
  lazy var bundlePath: URL = {
    let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    DPrint("\n DIRECTORY: \(documents.absoluteString)\n")
    let bundlePath = documents.appendingPathComponent(RuntimeLocalizable.bundleName, isDirectory: true)
    
    return bundlePath
  }()
  
  // Methods
  public func cleanTranslations() throws {
    let manager = FileManager.default
    
    for item in manager.enumerator(at: bundlePath, includingPropertiesForKeys: nil, options: [.skipsPackageDescendants])! {
      DPrint(item)
    }
    
    if manager.fileExists(atPath: bundlePath.path) {
      try manager.removeItem(at: bundlePath)
    }
    
    localizedBundle = nil
  }
  
  public func save(translations: Translations) throws {
    // TODO: Bundle is getting cached within the session, maybe rename the bundle for each version?
    let manager = FileManager.default
    if manager.fileExists(atPath: bundlePath.path) == false {
      try manager.createDirectory(at: bundlePath, withIntermediateDirectories: true, attributes: nil)
    }
    
    for language in translations {
      let lang = language.key
      let langPath = bundlePath.appendingPathComponent("\(lang).lproj", isDirectory: true)
      if manager.fileExists(atPath: langPath.path) == false {
        try manager.createDirectory(at: langPath, withIntermediateDirectories: true, attributes: nil)
      }
      
      let sentences = language.value
      let res = sentences.reduce("", { $0 + "\"\($1.key)\" = \"\($1.value)\";\n" })
      
      let filePath = langPath.appendingPathComponent("\(RuntimeLocalizable.tableName).strings")
      let data = res.data(using: .utf32)
      manager.createFile(atPath: filePath.path, contents: data, attributes: nil)
    }
    localizedBundle = Bundle(url: bundlePath)!
  }
}
