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
    
    
    var category = ["Мясо","Овощи и фрукты", "Пекарня", "Молочка, Сыры", "Сладости"]
    var uom = [UomType]()
    var increment = [String]()
    
    var pickerType: PickerType = .category
    
    
    @IBOutlet weak var commonPickerView: UIPickerView!
    var item: ShopItem?
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var uomButton: UIButton!
    
    
    var delegate: Exchange!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for u in iterateEnum(uomType.self) {
            print(u.rawValue)
            uom.append(UomType(uom: u.rawValue, incremenet: u.increment))
            
            
            
        }
        
        
        itemTitle.delegate = self
        itemPrice.delegate = self
        commonPickerView.delegate = self
        commonPickerView.dataSource = self
        
        addDoneButtonToNumPad()

        if let item = item {
            itemTitle.text = item.name
            itemPrice.text = item.price.asDecimal
            categoryButton.setTitle(item.category, for: .normal)
        }
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
        
        item?.name = itemTitle.text!
        item?.price = (itemPrice.text?.double)!
        delegate.objectExchange(object: item!)
        self.dismiss(animated: true, completion: nil)
    }
   

}

//MARK: Picker
extension ItemCardVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerType == .category ? category.count : uom.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerType == .category ? category[row] : uom[row].uom
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        commonPickerView.isHidden = true
        if pickerType == .category {
            categoryButton.setTitle(category[row], for: .normal)
            item?.category = category[row]
        } else {
            uomButton.setTitle(uom[row].uom, for: .normal)
            item?.uom = uom[row]
            
        }
    }
    
    
}

// MARK: enum as Sequence
extension ItemCardVC {
    
    func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
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

