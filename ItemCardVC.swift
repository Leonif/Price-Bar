//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemCardVC: UIViewController {
    
    
    var category = ["Овощи и фрукты", "Пекарня"]
    
    @IBOutlet weak var categoryPickerView: UIPickerView!
    var item: ShopItem?
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    
    var delegate: Exchange!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTitle.delegate = self
        itemPrice.delegate = self
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self

        if let item = item {
            itemTitle.text = item.name
            itemPrice.text = String(format:"%.2f", item.price)
            categoryButton.setTitle(item.category, for: .normal)
        }
    }

   
    @IBAction func categoryPressed(_ sender: Any) {
        
        categoryPickerView.isHidden = false
        
        
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        
        item?.name = itemTitle.text!
        item?.price = (itemPrice.text?.double)!
        delegate.itemChanged(item: item!)
        self.dismiss(animated: true, completion: nil)
    }
   

}


extension ItemCardVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryButton.setTitle(category[row], for: .normal)
        categoryPickerView.isHidden = true
        item?.category = category[row]
    }
    
    
}



extension ItemCardVC: UITextFieldDelegate {
    //hide keyboard by press ENter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

