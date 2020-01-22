//
//  ColorPickerView.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

protocol ColorPickerViewDelegate {
    func selectColorAction(colorHex: String)
}

private enum Constants {
    static let hexPrefix = "#"
    static let hexColorSymbolsCount = 6
}

class ColorPickerView: UIView {
    
    var delegate    : ColorPickerViewDelegate?
    
    var selectedButtonTag : Int = -1
    var selectedHexColor : String = ""
    
    let k_buttonsInRow = 6
    let k_buttonsRows = 6
    let k_spaceBetweenButtons : CGFloat = 10.0
    
    var colorsArray = [UIColor]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        colorsArray = ["#ced4da", "#868e96", "#212529", "#da77f2", "#be4bdb", "#8e44ad", "#f783ac", "#e64980", "#a61e4d",  "#748ffc", "#4c6ef5", "#364fc7", "#9775fa", "#7950f2", "#5f3dc4", "#ff8787", "#fa5252", "#c0392b",  "#4dabf7", "#3498db", "#1864ab", "#2ecc71", "#27ae60", "#16a085", "#ffd43b", "#fab005", "#e67e22",  "#3bc9db", "#15aabf", "#0b7285", "#a9e34b", "#82c91e", "#5c940d", "#f39c12", "#fd7e14", "#e74c3c"]
            .compactMap { return UIColor(hex: $0) }
    }
    
    func setupColorPicker(width: CGFloat) {
        let buttonWidth = self.calculateButtonWidth(viewWidth: width)
        self.setButtons(buttonWidth: buttonWidth)
        
        if self.selectedButtonTag > 0 {
            self.setButtonSelected(tag: self.selectedButtonTag)
        }
        let lastButton = subviews.last
        self.frame = CGRect(origin: .zero, size: CGSize(width: width, height: lastButton?.frame.maxY ?? 0))
    }
    
    func setButtons(buttonWidth: CGFloat) {
        
        var index = 0
        
        for indexY in 0...k_buttonsRows - 1 {
            
            let yPosition = (buttonWidth + k_spaceBetweenButtons) * CGFloat(indexY)
            
            for indexX in 0...k_buttonsInRow - 1 {
                
                let xPosition = (buttonWidth + k_spaceBetweenButtons) * CGFloat(indexX)
                
                index = index + 1
                
                self.createButton(x: xPosition, y: yPosition, buttonWidth: buttonWidth, tag: index)
            }
        }
    }
    
    func calculateButtonWidth(viewWidth: CGFloat) -> CGFloat {
        
        let buttonsAreaWidth = viewWidth - CGFloat(k_buttonsInRow - 1) * k_spaceBetweenButtons
        let buttonWidth = buttonsAreaWidth / CGFloat(k_buttonsInRow)
        
        return buttonWidth
    }
    
    func createButton(x: CGFloat, y: CGFloat, buttonWidth: CGFloat, tag: Int) {
        guard colorsArray.count >= tag else {
            return
        }
        let frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonWidth)
        let button = UIButton(frame: frame)
        button.backgroundColor = colorsArray[tag - 1]
        button.layer.cornerRadius = buttonWidth / 2
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.tag = k_colorButtonsTag + tag
        button.addTarget(self, action:#selector(buttonPressed(_:)), for: .touchUpInside)
        self.add(subview: button)
    }
    
    func setButtonSelected(tag: Int) {
        
        self.clearSelection()
        
        if let button = self.viewWithTag(tag) {
            (button as! UIButton).setImage(UIImage(named: k_selectedColorImageName), for: .normal)
        }
    }
    
    func clearSelection() {
        
        for index in 1...colorsArray.count {
            
            let tag = index + k_colorButtonsTag
            if let button = self.viewWithTag(tag) {
                (button as! UIButton).setImage(UIImage(), for: .normal)
            }
        }
    }
    
    //MARK: - IBActions
    
    @objc func buttonPressed(_ sender: UIButton) {
        
        let tag = sender.tag
        self.setButtonSelected(tag: tag)
        self.selectedButtonTag = tag
        self.selectedHexColor = self.getSelectedColor(tag: tag).hexString
        
        delegate?.selectColorAction(colorHex: self.selectedHexColor)
    }
    
    func getSelectedColor(tag: Int) -> UIColor {
        
        let index = tag - k_colorButtonsTag - 1
        
        if index < self.colorsArray.count {
            let selectedColor = self.colorsArray[index]
            return selectedColor
        } else {
            return UIColor.black
        }
    }
    
    func findColorIndexTag(colorHex: String) -> Int {
        
        var colorIndex = -1
        
        for (index, color) in self.colorsArray.enumerated() {
            
            let arrayColorHex = color.hexString
            if arrayColorHex == colorHex {
                colorIndex = index
            }
        }
        
        return colorIndex
    }
}

extension UIColor {
    
    var hexString: String {
        
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }

    convenience init(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix(Constants.hexPrefix) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
}
