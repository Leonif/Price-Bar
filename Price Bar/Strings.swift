//
//  Strings.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum Strings {
    
    enum Segues: String {
        case showScan
        case showItemList
//        case showOutlets
        case showEditItem
//        case scannedNewProduct
        
        var name: String {
            return self.rawValue
        }
    }
}





