//
//  QuantityPickerPopup2.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/1/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol QuantityPickerPopupDelegate2 {
    func choosen(weight: Double, for indexPath: IndexPath)
}


struct WeightItem {
    
    var weight: [Double]
    var suff: String
    
}

class QuantityPickerPopup2: UIViewController {
    
    var weightItems = [WeightItem]()
//    var wholeItems = [Int]()
//    var decimalItems = [Int]()
    var indexPath: IndexPath?
    var type: QuantityType?
    var delegate: QuantityPickerPopupDelegate2?
    var currentModel: QuantityModel2!
    
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
    
    convenience init(delegate: QuantityPickerPopupDelegate2, model: QuantityModel2) {
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
        
//        let wholePart = wholeItems[weightPicker.selectedRow(inComponent: 0)]
//
//        var quantity = Double(wholePart)
//        if currentModel.type == .weight {
//            let decimalPart = decimalItems[weightPicker.selectedRow(inComponent: 1)]
//            quantity += Double(decimalPart)/1000.0
//        }
//
//        delegate?.choosen(weight: quantity, for: self.currentModel.indexPath)
//        self.view.antiObscure {
//            self.dismiss(animated: true, completion: nil)
//        }
        
    }
    
    @objc func cancelSelection() {
        self.view.antiObscure {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func configurePopup() {
        weightPicker.delegate = self
        for (index, k) in self.currentModel.koefficients.enumerated()  {
            let w = Array(0...1000).map { Double($0) * k }
            weightItems.append(WeightItem(weight: w, suff: self.currentModel.suffixes[index]))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
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

extension QuantityPickerPopup2: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let w = weightItems[component].weight[row]
        let suff = weightItems[component].suff
        
        return "\(w)" "\(suff)"
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return weightItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return weightItems[component].weight.count
        
    }
}
