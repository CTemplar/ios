//
//  UINavBar+Borderline.swift
//  Ctemplar
//
//  Created by Majid Hussain on 29/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit

public extension UINavigationBar {
    
    func showBorderLine() {
        findBorderLine().isHidden = false
    }
    
    func hideBorderLine() {
        findBorderLine().isHidden = true
    }
    
    private func findBorderLine() -> UIImageView! {
        return self.subviews
            .flatMap { $0.subviews }
            .compactMap { $0 as? UIImageView }
            .filter { $0.bounds.size.width == self.bounds.size.width }
            .filter { $0.bounds.size.height <= 2 }
            .first
    }
}
