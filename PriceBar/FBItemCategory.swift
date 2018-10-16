//
//  FBItemCategory.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

class FBItemCategoryEntity {
    var id: Int32 = 0
    var name = ""

    init() {

    }

    init(key: Int32, itemCategoryDict: Dictionary<String, Any>) {
        if let name = itemCategoryDict["name"] as? String {
            self.id = key
            self.name = name
        }
    }

    init(id: Int32, name: String) {
        self.id = id
        self.name = name
    }
}



