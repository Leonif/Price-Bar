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


class QuantityPickerPopup: UIViewController {
    
    var wholeItems = [Int]()
    var decimalItems = [Int]()
    var type: QuantityType?
    
    
    let weightPicker : UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        picker.backgroundColor = .blue
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
   
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    convenience init(type: QuantityType) {
        self.init()

        self.type = type
        self.configurePopup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configurePopup()
    }
    
    
    func configurePopup() {
        for i in 0...100 {
            wholeItems.append(i)
        }
        
        if type == .weight {
            for i in 0...1000 {
                //let w = Double(i)
                decimalItems.append(i)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .red
        self.view.addSubview(weightPicker)
        weightPicker.delegate = self
        weightPicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        weightPicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        weightPicker.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        weightPicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        
        
    }
    
    
}

extension QuantityPickerPopup: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if type == .weight {
            return component == 0 ? "\(wholeItems[row]) kg" : "\(decimalItems[row]) gr"
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
















