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
    
    
    
    
    var categories = [Category]()
    var uom = [Uom]()
    var increment = [String]()
    var pickerType: PickerType = .category
    var outletId: String!
    
    
    @IBOutlet weak var commonPickerView: UIPickerView!
    var item: ShopItem?
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var uomButton: UIButton!
    
    
    var delegate: Exchange!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        readInitData()
        itemTitle.delegate = self
        itemPrice.delegate = self
        commonPickerView.delegate = self
        commonPickerView.dataSource = self
        
        addDoneButtonToNumPad()

        if let item = item {
            itemTitle.text = item.name
            itemPrice.text = item.price.asDecimal
            categoryButton.setTitle(item.category, for: .normal)
            uomButton.setTitle(item.uom.uom, for: .normal)
        } else {
            
            item = ShopItem(id: UUID().uuidString, name: "Дайте название", quantity: 1.0, price: 0.0, category: categories[0].category!, uom: ShopItemUom(), outletId: outletId, scanned: false)
            
           
            
        }
    }
    
    func readInitData() {
        
        let initData = ShopListModel().readInitData()
        categories = initData.categories
        uom = initData.uoms
    }
    
    
   
    @IBAction func categoryPressed(_ sender: Any) {
        
        pickerType = .category
        commonPickerView.reloadAllComponents()
        
        commonPickerView.isHidden = false
        
        
    }
    
    @IBAction func uomPressed(_ sender: Any) {
    
        pickerType = .uom
        commonPickerView.reloadAllComponents()
        commonPickerView.isHidden = false
    
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
        return pickerType == .category ? categories.count : uom.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerType == .category ? categories[row].category : uom[row].uom
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        commonPickerView.isHidden = true
        if pickerType == .category {
            categoryButton.setTitle(categories[row].category, for: .normal)
            item?.category = categories[row].category!
            //catRow = row
        } else {
            uomButton.setTitle(uom[row].uom, for: .normal)
            item?.uom = ShopItemUom(uom: uom[row].uom!,increment: uom[row].iterator)
            
        }
    }
    
    
}





extension ItemCardVC: UITextFieldDelegate {
    //hide keyboard by press ENter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numDonePressed() {
        
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

