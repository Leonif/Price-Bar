//
//  ProjectExtensions.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/13/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit


extension UILabel {
    
    func update(value: Double) {
        self.text = "Итого: \(value.asLocaleCurrency)"
    }
    
    
}
