//
//  AppFont.swift
//  Sub
//


import Foundation
import UIKit

private let familyName = "Avenir"

enum AppFont: String {
    
    case light = "Light"
    case book = "Book"
    case roman = "Roman"
    case bookOblique = "BookOblique"
    case oblique = "Oblique"
    case lightOblique = "LightOblique"
    case medium = "Medium"
    case mediumOblique = "MediumOblique"
    case heavy = "Heavy"
    case heavyOblique = "HeavyOblique"
    case black = "Black"
    case blackOblique = "BlackOblique"
    
    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size + 1.0) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    fileprivate var fullFontName: String {
        return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
