import Foundation

public extension Bundle {
    private static var bundle: Bundle!
    
    static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }
        return bundle
    }
    
    static func setLanguage(lang: String) {
        DPrint("set language:", lang)
        UserDefaults.standard.set(lang, forKey: "app_lang")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
    
    static func getLanguage() -> String {
        let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
        return appLang
    }
    
    static func currentDeviceLanguageCode() -> String? {
        let locale = Locale.current.languageCode
        return locale
    }
    
    static func currentAppLanguage() -> String? {
        let preferredLanguages = Locale.preferredLanguages.first
        return preferredLanguages
    }
    
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
