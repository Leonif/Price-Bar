//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

enum PickerType {
    case category
    case uom
}





class ItemCardVC: UIViewController {
    var categories = [ItemCategory]()
    var uoms = [ItemUom]()
    //var uoms = [Uom]()
    var increment = [String]()
    var pickerType: PickerType = .category
    var outletId: String!
    var searchedItemName: String?
    
    
    @IBOutlet weak var commonPickerView: UIPickerView!
    var item: ShopItem?
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var uomButton: UIButton!
    
    
    var delegate: Exchange!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initController()
        cardOpenHandler()

        
    }
    
    func initController() {
        itemTitle.delegate = self
        itemPrice.delegate = self
        commonPickerView.delegate = self
        commonPickerView.dataSource = self
        
        //load categories
        categories = CoreDataService.data.getCategoriesFromCoreData()
        uoms = CoreDataService.data.getUomsFromCoreData()
        
        
        addDoneButtonToNumPad()
        
    }
    
    
    func cardOpenHandler() {
        if item == nil {
            if let newName = searchedItemName {
                
                let itemCategory = ItemCategory(id: categories[0].id, name: categories[0].name)
                let itemUom = ItemUom(id: uoms[0].id, name: uoms[0].name, iterator: uoms[0].iterator)
                
                item = ShopItem(id: UUID().uuidString, name: newName.capitalized, quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: false, checked: false)
            }
        }
        if let item = item {
            itemTitle.text = item.name
            itemPrice.text = item.price.asDecimal
            categoryButton.setTitle(item.itemCategory.name, for: .normal)
            uomButton.setTitle(item.itemUom.name, for: .normal)
        }
        
        
    }
    
   
    @IBAction func categoryPressed(_ sender: Any) {
        
        self.view.endEditing(true)
        pickerType = .category
        commonPickerView.reloadAllComponents()
        commonPickerView.isHidden = false
        
        guard let item = item else {
            return
        }
        for index in 0 ..< categories.count {
            if categories[index] == item.itemCategory {
                commonPickerView.selectRow(index, inComponent: 0, animated: true)
                break
            }
 
        }
        
        
        
    }
    
    @IBAction func uomPressed(_ sender: Any) {
    
        self.view.endEditing(true)
        pickerType = .uom
        commonPickerView.reloadAllComponents()
        commonPickerView.isHidden = false
        
        guard let item = item else {
            return
        }
        
        for index in 0 ..< uoms.count {
            if uoms[index].name == item.itemUom.name {
                commonPickerView.selectRow(index, inComponent: 0, animated: true)
                break
            }
            
        }
        
    
    }
    
    
    
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        if let item = item {
            item.name = itemTitle.text ?? ""
            item.price = itemPrice.text?.double ?? 0.0
            delegate.objectExchange(object: item)
            
        } else {
            self.item?.name = itemTitle.text ?? ""
            self.item?.price = itemPrice.text?.double ?? 0.0
            delegate.objectExchange(object: item!)
            
            print("Product is not saved")
        }
        self.dismiss(animated: true, completion: nil)
    }
   

}

//MARK: Picker
extension ItemCardVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerType == .category ? categories.count : uoms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerType == .category ? categories[row].name : uoms[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        commonPickerView.isHidden = true
        if pickerType == .category {
            categoryButton.setTitle(categories[row].name, for: .normal)
            item?.itemCategory = categories[row]
            //catRow = row
        } else {
            uomButton.setTitle(uoms[row].name, for: .normal)
            item?.itemUom = uoms[row]
            
        }
    }
    
    
}





extension ItemCardVC: UITextFieldDelegate {
    //hide keyboard by press ENter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.animateViewMoving(up: true, moveValue: 150, view: self.view)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.animateViewMoving(up: false, moveValue: 150, view: self.view)
    }

    
    @objc func numDonePressed() {
        
        itemPrice.resignFirstResponder()
        
    }
    
    
    func addDoneButtonToNumPad() {
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(numDonePressed))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        itemPrice.inputAccessoryView = toolbarDone
    }
}

