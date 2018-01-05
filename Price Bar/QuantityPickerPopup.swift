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

protocol QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath)
}


class QuantityPickerPopup: UIViewController {
    
    var wholeItems = [Int]()
    var decimalItems = [Int]()
    var indexPath: IndexPath?
    var type: QuantityType?
    var delegate: QuantityPickerPopupDelegate?
    
    
    let weightPicker: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        picker.backgroundColor = .blue
        picker.isUserInteractionEnabled = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let toolbar: UIToolbar = {
        let tb = UIToolbar(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        tb.backgroundColor = .yellow
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
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
    
    @objc func choosen() {
        
        var quantity = Double(wholeItems[weightPicker.selectedRow(inComponent: 0)])
        if type == .weight {
            quantity += Double(decimalItems[weightPicker.selectedRow(inComponent: 1)])/1000.0
        }
        
        delegate?.choosen(weight: quantity, for: indexPath!)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func cancelSelection() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func configurePopup() {
        
        wholeItems = Array(0...100)
        
        if type == .weight {
            decimalItems = Array(0...1000)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let but = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        but.addTarget(self, action: #selector(choosen), for: .touchUpInside)
        but.backgroundColor = .red
        self.view.addSubview(but)
        
        
        self.view.obscure()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.choosen))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelSelection))
        toolbar.items = [doneButton, cancelButton]
        
        weightPicker.addSubview(toolbar)
        
        toolbar.leadingAnchor.constraint(equalTo: weightPicker.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: weightPicker.trailingAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        toolbar.topAnchor.constraint(equalTo: weightPicker.topAnchor).isActive = true
        
        
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
















