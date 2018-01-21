//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ItemCardVCDelegate {
    func updated(status: Bool)
    func add(new productId: String)
}


class ItemCardVC: UIViewController {
    enum PickerType {
        case category
        case uom
    }
    
    enum CardState {
        case createMode
        case editMode
    }
    
    var state: CardState!
    
    var categories:[CategoryModelView] = []
    var uoms: [UomModelView] = []
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?
    var dataProvider: DataProvider!
    
    
    @IBOutlet weak var commonPickerView: UIPickerView!
    var item: DPShoplistItemModel?
    var barcode: String?
    var productCard: ProductCardModelView!
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var uomButton: UIButton!
    
    var delegate: ItemCardVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
        cardOpenHandler()
    }
    
    func initController() {
        itemTitle.delegate = self
        itemPrice.delegate = self
        
        //load categories
        guard let dpCategoryList = dataProvider.getCategoryList() else {
            fatalError("Category list is empty")
        }
        
        for category in dpCategoryList {
            self.categories.append(mapper(from: category))
        }
        
        guard let uoms = dataProvider.getUomList() else {
            fatalError("Catgory list is empty")
        }
        self.uoms = uoms
    }
    
    private func mapper(from dpCategory: DPCategoryModel) -> CategoryModelView {
        return CategoryModelView(id: dpCategory.id, name: dpCategory.name)
    }
    
    
    private func cardOpenHandler() {
        if let item = item {
            state = CardState.editMode
            self.productCard = mapper(from: item)
            updateUI(for: productCard)
            
        }
        
        if let barcode = self.barcode {
            state = CardState.createMode
            print("New product")
            self.productCard = mapper(from: barcode)
            updateUI(for: productCard)
        }
        
    }
    
    
    func updateUI(for productCard: ProductCardModelView) {
        itemTitle.text = productCard.productName
        itemPrice.text = "\(productCard.productPrice)"
        categoryButton.setTitle(productCard.categoryName, for: .normal)
        uomButton.setTitle(productCard.uomName, for: .normal)
        
    }
    
    
    private func mapper(from newBarcode: String) -> ProductCardModelView {
        
        
        
        guard let category = dataProvider.defaultCategory else {
            fatalError("default category is not found")
        }
        
        guard let uom = dataProvider.defaultUom else {
            fatalError("default uom is not found")
        }
        
        
        return ProductCardModelView(productId: newBarcode,
                                              productName: "",
                                              categoryId: category.id,
                                              categoryName: category.name,
                                              productPrice: 0.0,
                                              uomId: uom.id,
                                              uomName: uom.name)
    }
    
    private func mapper(from item: DPShoplistItemModel) -> ProductCardModelView {
        return ProductCardModelView(productId: item.productId,
                                    productName: item.productName,
                                    categoryId: item.categoryId,
                                    categoryName: item.productCategory,
                                    productPrice: item.productPrice,
                                    uomId: item.uomId,
                                    uomName: item.productUom)
    }
    
   
    @IBAction func categoryPressed(_ sender: Any) {
        self.view.endEditing(true)
       
        self.pickerType = PickerType.category
        var pickerData: [PickerData] = []
        var curentIndex = 0
        for (index, category) in categories.enumerated() {
            if productCard.categoryId == category.id {
                curentIndex = index
            }
            pickerData.append(PickerData(id: category.id, name: category.name))
        }
        
        let picker = PickerControl(delegate: self,
                                   dataSource: pickerData,
                                   currentIndex: curentIndex)
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func uomPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.pickerType = PickerType.uom
        var pickerData: [PickerData] = []
        var curentIndex = 0
        for (index, uom) in uoms.enumerated() {
            if productCard.uomId == uom.id {
                curentIndex = index
            }
            pickerData.append(PickerData(id: uom.id, name: uom.name))
        }
        let picker = PickerControl(delegate: self,
                                   dataSource: pickerData,
                                   currentIndex: curentIndex)
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {

        guard
            let name = itemTitle.text,
            !name.isEmpty,
            let priceStr = itemPrice.text,
            let price = priceStr.double,
            price != 0.0
            else {
                alert(title: "Ops", message: "Нельзя такое сохранять !!!")
                return
        }
        
        
        productCard.productName = name
        productCard.productPrice = price
       
        let dpProductCardModel = DPUpdateProductModel(id: productCard.productId,
                                       name: productCard.productName,
                                       categoryId: productCard.categoryId,
                                       uomId: productCard.uomId)
        
        let dpStatModel = DPPriceStatisticModel(outletId: outletId,
                                                productId: productCard.productId,
                                                price: productCard.productPrice)
        
        if state == CardState.editMode {
            dataProvider.update(dpProductCardModel)
            delegate.updated(status: true)
        } else {
            dataProvider.save(new: dpProductCardModel)
        }
        
        dataProvider.save(new: dpStatModel)
        
        self.dismiss(animated: true, completion: nil)
    }
   

}

//MARK: Picker
extension ItemCardVC: PickerControlDelegate {
    func choosen(id: Int32) {
        print(id)
        if pickerType == PickerType.category {
            productCard.categoryId = id
            for category in categories {
                if category.id == id {
                    categoryButton.setTitle(category.name, for: .normal)
                    break
                }
            }
        } else {
            productCard.uomId = id
            for uom in uoms {
                if uom.id == id {
                    uomButton.setTitle(uom.name, for: .normal)
                    break
                }
            }
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
    
}

