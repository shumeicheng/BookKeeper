//
//  Client.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import RealmSwift

class Client: Object {
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var specialNotes: String = ""
    var dates = List<serviceDate>()
    var products = List<Product>()
}
