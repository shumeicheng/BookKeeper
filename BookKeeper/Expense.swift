//
//  Expense.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 2/11/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import RealmSwift
class Expense: Object {
    dynamic var name: String = ""
    dynamic var cost: Float = 0.0
    dynamic var date: Date?
    dynamic var image: NSData?
}
