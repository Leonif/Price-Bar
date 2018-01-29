//
//  QuantityPicker.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/5/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


protocol QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath)
}


class QuantityPickerPopup: UIViewController {
    
    var wholeItems = [Int]()
    var decimalItems = [Int]()
    var indexPath: IndexPath?
    var type: QuantityType?
    var delegate: QuantityPickerPopupDelegate?
    var currentModel: QuantityModel!
    
    let weightPicker: UIPickerView = {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        picker.backgroundColor = .white
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    let toolbar: UIToolbar = {
        let tlbr = UIToolbar()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelection))
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(choosen))
        tlbr.items = [cancelButton, flex, doneButton]
        tlbr.isUserInteractionEnabled = true
        return tlbr
    }()
    
    let containerView = UIView()
   
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(delegate: QuantityPickerPopupDelegate, model: QuantityModel) {
        self.init()
        self.delegate = delegate
        self.currentModel = model
        self.configurePopup()
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.configurePopup()
    }
    
    @objc func choosen() {
        
        let wholePart = wholeItems[weightPicker.selectedRow(inComponent: 0)]
        
        var quantity = Double(wholePart)
        if currentModel.type == .weight {
            let decimalPart = decimalItems[weightPicker.selectedRow(inComponent: 1)]
            quantity += Double(decimalPart)/1000.0
        }
        
        delegate?.choosen(weight: quantity, for: self.currentModel.indexPath)
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
        weightPicker.delegate = self
        
        wholeItems = Array(0...100)

        if currentModel.type == .weight {
            decimalItems = Array(0...1000).filter { $0 % 10 == 0 }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         setupConstraints()
        
        guard let wholePartIndex = wholeItems.index(of: currentModel.wholeItem)  else {
            return
        }
        weightPicker.selectRow(wholePartIndex, inComponent: 0, animated: true)
        
        if currentModel.type == .weight  {
            guard let decimalPartIndex = decimalItems.index(of: currentModel.decimalItem) else {
                return
            }
            weightPicker.selectRow(decimalPartIndex, inComponent: 1, animated: true)
        }
    }
    
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        weightPicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(toolbar)
        containerView.addSubview(weightPicker)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50.0),
            weightPicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            weightPicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            weightPicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            weightPicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.obscure()
    }
    
    
}

extension QuantityPickerPopup: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if currentModel.type == .weight {
            return component == 0 ? "\(wholeItems[row]) кг" : "\(decimalItems[row]) гр"
        }
        
        return "\(wholeItems[row]) шт"
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return currentModel.type == .weight ? 2 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if currentModel.type == .weight {
            return component == 0 ? wholeItems.count : decimalItems.count
        }
        
        return wholeItems.count
    }
}
















