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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        //self.backgroundColor = UIColor.green
    }
    
    func setupColorPicker(width: CGFloat, height: CGFloat) {        
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let buttonWidth = self.calculateButtonWidth(viewWidth: width)
        
        var index = 0
        
        for indexY in 0...k_buttonsRows - 1 {
            
            let yPosition = (buttonWidth + k_spaceBetweenButtons) * CGFloat(indexY)
        
            for indexX in 0...k_buttonsInRow - 1 {
            
                let xPosition = (buttonWidth + k_spaceBetweenButtons) * CGFloat(indexX)
            
                index = indexX + indexY
            
                self.createButton(x: xPosition, y: yPosition, buttonWidth: buttonWidth, tag: index + 1)
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
        button.backgroundColor = UIColor.orange
        button.tag = tag
        self.add(subview: button)
    }
    
    //MARK: - IBActions
    
    @IBAction func tappedAction(_ sender: UIButton) {
        delegate?.selectAction(sender)
    }
}
