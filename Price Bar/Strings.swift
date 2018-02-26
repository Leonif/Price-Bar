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
        case showOutlets
        case showEditItem
        case scannedNewProduct
        
        var name: String {
            return self.rawValue
        }
    }
    
    
    enum Alerts: String {
        case good_news
        case try_later
        case wow
        case clean_shoplist
        case not_necessary
        case ups
        
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    
    enum ActivityIndicator: String {
        case outlet_looking
        case sync_process
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
        
    }
    
    enum Common: String {
        case total
        case loading
        case outlet_loading
        
        
        var localized: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
        
    }
    
    
}





