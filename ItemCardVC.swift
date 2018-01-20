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
    var categories:[CategoryModel] = []
    var uoms: [UomModel] = []
    //var increment = [String]()
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?
    var dataProvider: DataProvider!
    
    
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
//        itemTitle.delegate = self
//        itemPrice.delegate = self
//        commonPickerView.delegate = self
//        commonPickerView.dataSource = self
        
        
        //uoms = CoreDataService.data.getUomsFromCoreData()
        //addDoneButtonToNumPad()
    }
    
    
    func cardOpenHandler() {
//        if item == nil {
//            if let newName = searchedItemName {
//
//                let itemCategory = ItemCategory(id: categories[0].id, name: categories[0].name)
//                let itemUom = ItemUom(id: uoms[0].id, name: uoms[0].name, iterator: uoms[0].iterator)
//
//                item = ShopItem(id: UUID().uuidString, name: newName.capitalized, quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, itemUom: itemUom, outletId: outletId, scanned: false, checked: false)
//            }
//        }
//        if let item = item {
//            itemTitle.text = item.name
//            itemPrice.text = item.price.asDecimal
//            categoryButton.setTitle(item.itemCategory.name, for: .normal)
//            uomButton.setTitle(item.itemUom.name, for: .normal)
//        }
    }
    
   
    @IBAction func categoryPressed(_ sender: Any) {
        
        self.view.endEditing(true)
        
        //load categories
        guard let categories = dataProvider.getCategoryList() else {
            fatalError("Catgory list is empty")
        }
        self.categories = categories
        var pickerData: [PickerData] = []
        for category in categories {
            pickerData.append(PickerData(id: category.id, name: category.name))
        }
        
        let picker = PickerControl(delegate: self, dataSource: pickerData, currentIndex: 0)
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func uomPressed(_ sender: Any) {
    
        self.view.endEditing(true)
        
        guard let uoms = dataProvider.getUomList() else {
            fatalError("Catgory list is empty")
        }
        self.uoms = uoms
        var pickerData: [PickerData] = []
        for uom in uoms {
            pickerData.append(PickerData(id: uom.id, name: uom.name))
        }
        
        let picker = PickerControl(delegate: self, dataSource: pickerData, currentIndex: 0)
        self.present(picker, animated: true, completion: nil)
        
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
extension ItemCardVC: PickerControlDelegate {
    func choosen(id: Int32) {
        print(id)
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
        let toolbarDone = UIToolbar()
        toolbarDone.sizeToFit()
        let flex = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace,
                                              target: self, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: .done,
                                              target: self, action: #selector(numDonePressed))
        
        toolbarDone.items = [flex, barBtnDone] // You can even add cancel button too
        itemPrice.inputAccessoryView = toolbarDone
    }
}

