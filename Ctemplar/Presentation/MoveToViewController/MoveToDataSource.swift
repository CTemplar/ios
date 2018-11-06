//
//  MoveToDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class MoveToDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    
    //MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "moveToCellIdentifier")!
        
        return cell
    }
}
