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


class ToolBarView: UIView {
    
    let doneButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        btn.setTitle("Done", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()
    let cancelButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.systemGray
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.systemGray
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.addSubview(doneButton)
        self.addSubview(cancelButton)
        
        let margin = self.layoutMarginsGuide
        
        cancelButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        
    }
    
}


class QuantityPickerPopup: UIViewController {
    
    var wholeItems = [Int]()
    var decimalItems = [Int]()
    var indexPath: IndexPath?
    var type: QuantityType?
    var delegate: QuantityPickerPopupDelegate?
    
    
    let weightPicker: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    let toolbar = ToolBarView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    
   
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
        self.view.antiObscure {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func cancelSelection() {
        self.view.antiObscure {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func configurePopup() {
        wholeItems = Array(0...100)
        if type == .weight {
            decimalItems = Array(100...1000)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.addSubview(weightPicker)
        weightPicker.delegate = self
        weightPicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        weightPicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        weightPicker.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        weightPicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.doneButton.addTarget(self, action: #selector(choosen), for: .touchUpInside)
        toolbar.cancelButton.addTarget(self, action: #selector(cancelSelection), for: .touchUpInside)
        self.view.addSubview(toolbar)
        
        toolbar.leadingAnchor.constraint(equalTo: weightPicker.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: weightPicker.trailingAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: weightPicker.topAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.obscure()
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
















