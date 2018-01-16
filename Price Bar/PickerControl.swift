//
//  PickerControl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/16/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


protocol PickerControlDelegate {
    func choosen(indexPath: Int)
}


class PickerControl: UIViewController {
    
    
    var dataSource: [String] = []
    var indexPath: IndexPath?
    
    var delegate: PickerControlDelegate?
    
    
    
    let picker: UIPickerView = {
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
    
    convenience init(delegate: PickerControlDelegate, dataSource: [String], currentIndex: Int) {
        self.init()
        
        self.delegate = delegate
        self.dataSource = dataSource
        self.picker.selectRow(currentIndex, inComponent: 0, animated: true)
        self.configurePopup()
        self.modalPresentationStyle = .overCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.configurePopup()
    }
    
    @objc func choosen() {
        delegate?.choosen(indexPath: picker.selectedRow(inComponent: 0))
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
        picker.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(toolbar)
        containerView.addSubview(picker)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            toolbar.topAnchor.constraint(equalTo: containerView.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 50.0),
            picker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.obscure()
    }
    
    
}

extension PickerControl: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return dataSource[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}

