//
//  Composer.swift
//  Networking
//


import Foundation
public struct Composer {
    // MARK: Properties
    public private (set) var color: String?
    public private (set) var backgroundColor: String?
    public private (set) var size: Int?
    public private (set) var font: String?
    
    // MARK: - Construtor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        self.color = dictionary["default_color"] as? String
        self.backgroundColor = dictionary["default_background"] as? String
        self.size = dictionary["default_size"] as? Int
        self.font = dictionary["plain_text_font"] as? String
    }
    
    static public func composerData(model: [String])-> Composer {
        var composer = Composer()
        composer.color = model[0]
        composer.backgroundColor = model[1]
        composer.size = Int(model[2])
        composer.font = model[3]
        return composer
    }
}
