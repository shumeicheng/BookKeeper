//
//  BalanceSheetTableViewCell.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 2/10/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import UIKit

protocol BalanceSheetControllerDelegate{
    func TakeAPicture()
}

class BalanceSheetTableViewCell : UITableViewCell{
    var delegate: BalanceSheetController?
    
    @IBOutlet weak var imageExpense: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    // add take a picture action
    @IBAction func PhotoButtonPress(_ sender: Any) {
        delegate?.TakeAPicture(tableCell: self)
  
    }
}
