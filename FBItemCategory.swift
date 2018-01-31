//
//  FBItemCategory.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

class FBItemCategory {
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

func == (lhs: FBItemCategory, rhs: FBItemCategory) -> Bool {
    var returnValue = false
    if (lhs.name == rhs.name) && (lhs.id == rhs.id) {
        returnValue = true
    }
    return returnValue
}


