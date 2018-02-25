//
//  Strings.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation



enum Segues: String {
    case showScan
    case showItemList
    case showOutlets
    case showEditItem
    
    
    var name: String {
        return self.rawValue
    }
}


enum Alerts: String {
    case goodNews
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    
}
