//
//  SplitViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.01.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = .automatic       
        //self.primaryEdge = .leading
    }
}
