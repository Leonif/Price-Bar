//
//  QuantityPicker.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/5/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

enum QuantityType {
    case weight, quantity
}

class QuantityPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var wholeItems = [Double]()
    var decimalItems = [Double]()
    let type: QuantityType
    
    init(type: QuantityType) {
        self.type = type
        
        for i in 0...100 {
            let w = Double(i)
            wholeItems.append(w)
        }
        
        if type == .weight {
            for i in 0...1000 {
                let w = Double(i) * 0.01
                decimalItems.append(w)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if type == .weight {
            return component == 0 ? String(wholeItems[row]) : String(decimalItems[row])
        }
        
        return String(wholeItems[row])
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return type == .weight ? 2 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if type == .weight {
            return component == 0 ? wholeItems.count : decimalItems.count
        }
        
        return wholeItems.count
    }
}
