//
//  Product.swift
//  BookKeeper
//
//  Created by Shu-Mei Cheng on 1/28/17.
//  Copyright © 2017 Shu-Mei Cheng. All rights reserved.
//

import Foundation
import RealmSwift

class Product: Object {
    dynamic var name: String = ""
    dynamic var cost: Float = 0.0
   
    let clients = LinkingObjects(fromType: Client.self, property: "products")
}


