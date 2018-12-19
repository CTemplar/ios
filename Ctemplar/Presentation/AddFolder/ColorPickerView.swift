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
    func selectAction(_ sender: UIButton)
}

class ColorPickerView: UIView {
    
    var delegate    : ColorPickerViewDelegate?
    
    let k_buttonsInRow = 7
    let k_buttonsRows = 2
    let k_spaceBetweenButtons : CGFloat = 10.0
    
    let k_color1: UIColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 168.0 / 255.0, alpha: 1.0)
    let k_color2: UIColor = UIColor(red: 208.0 / 255.0, green: 88.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
    let k_color3: UIColor = UIColor(red: 194.0 / 255.0, green: 108.0 / 255.0, blue: 199.0 / 255.0, alpha: 1.0)
    let k_color4: UIColor = UIColor(red: 117.0 / 255.0, green: 104.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0)
    let k_color5: UIColor = UIColor(red: 106.0 / 255.0, green: 169.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0)
    let k_color6: UIColor = UIColor(red: 95.0 / 255.0, green: 199.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
    let k_color7: UIColor = UIColor(red: 114.0 / 255.0, green: 187.0 / 255.0, blue: 116.0 / 255.0, alpha: 1.0)
    let k_color8: UIColor = UIColor(red: 196.0 / 255.0, green: 210.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
    let k_color9: UIColor = UIColor(red: 230.0 / 255.0, green: 193.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
    let k_color10: UIColor = UIColor(red: 230.0 / 255.0, green: 153.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    let k_color11: UIColor = UIColor(red: 207.0 / 255.0, green: 126.0 / 255.0, blue: 125.0 / 255.0, alpha: 1.0)
    let k_color12: UIColor = UIColor(red: 200.0 / 255.0, green: 147.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
    let k_color13: UIColor = UIColor(red: 156.0 / 255.0, green: 148.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
    let k_color14: UIColor = UIColor(red: 169.0 / 255.0, green: 196.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
    
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
        
        colorsArray = [k_color1, k_color2, k_color3, k_color4, k_color5, k_color6, k_color7, k_color8, k_color9, k_color10, k_color11, k_color12, k_color13, k_color14]
    }
    
    func setupColorPicker(width: CGFloat, height: CGFloat) {        
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let buttonWidth = self.calculateButtonWidth(viewWidth: width)
        
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
        
        let frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonWidth)
        let button = UIButton(frame: frame)
        button.backgroundColor = colorsArray[tag - 1]
        button.layer.cornerRadius = buttonWidth / 2
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.black.cgColor
        button.tag = tag
        self.add(subview: button)
    }
    
    //MARK: - IBActions
    
    @IBAction func tappedAction(_ sender: UIButton) {
        delegate?.selectAction(sender)
    }
}