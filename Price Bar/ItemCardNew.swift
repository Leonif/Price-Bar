//
//  ItemCardNew.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

protocol ItemCardVCDelegate: class {
    func productUpdated()
    func add(new productId: String)
}

class ItemCardNew: UIViewController {
    enum PickerType {
        case category, uom
    }
    enum CardState {
        case createMode, editMode
    }
    
    var state: CardState!
    
    var categories: [CategoryModelView] = []
    var uoms: [UomModelView] = []
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?
    weak var repository: Repository!

    var item: DPShoplistItemModel?
    var barcode: String?
    var productCard: ProductCardModelView!
    
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemBrand: UITextField!
    @IBOutlet weak var itemWeight: UITextField!
    @IBOutlet weak var uomButton: UIButton!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    weak var delegate: ItemCardVCDelegate!
    
    var activeField: UITextField!
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        [itemName, itemBrand, itemWeight, uomButton, itemPrice, categoryButton, saveButton].forEach {
            PriceBarStyles.grayBorderedRoundedView.apply(to: $0)
        }
        [itemName, itemBrand, itemWeight, itemPrice].forEach {
            $0!.delegate = self
            self.addToolBar(textField: $0!)
        }
        
        //load categories
        guard let dpCategoryList = repository.getCategoryList() else {
            fatalError("Category list is empty")
        }
        
        self.categories = dpCategoryList.map { CategoryMapper.mapper(from: $0) }
        
        guard let uoms = repository.getUomList() else {
            fatalError("Catgory list is empty")
        }
        self.uoms = uoms
        self.cardOpenHandler()
        
        self.setupKeyboardObserver()
    }
    
    func setupKeyboardObserver() {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        
    }
    
    
    private func cardOpenHandler() {
        if let item = item {
            state = CardState.editMode
            self.productCard = ProductMapper.mapper(from: item)
            updateUI(for: productCard)
            
        }
        
        if let barcode = self.barcode {
            state = CardState.createMode
            print("New product")
            self.productCard = ProductMapper.mapper(from: barcode)
            updateUI(for: productCard)
        }
        
        if let searchText = self.searchedItemName {
            state = CardState.createMode
            print("New product")
            self.productCard = ProductMapper.mapper(for: searchText)
            updateUI(for: productCard)
            
        }
    }
    
    func updateUI(for productCard: ProductCardModelView) {
        itemName.text = productCard.productName
        itemPrice.text = "\(productCard.productPrice)"
        
        categoryButton.setTitle(productCard.categoryName, for: .normal)
        uomButton.setTitle(productCard.uomName, for: .normal)
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
    
    
    
    
    
    @objc
    func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset.bottom = 0
    }
    
        
        
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollView.contentInset.bottom = keyboardSize.height
        }
    }
    
    
    
    @IBAction func onCloseTap(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        guard
            let name = itemName.text,
            !name.isEmpty
            else {
                self.alert(title: "Агинь", message: "Заполните название товара 👿 !!!")
                return
        }
        self.saveProduct(with: name)
        self.saveStatistic()
    }
    
    private func saveProduct(with name: String) {
        productCard.productName = name
        let dpProductCardModel = DPUpdateProductModel(id: productCard.productId,
                                                      name: productCard.productName,
                                                      categoryId: productCard.categoryId,
                                                      uomId: productCard.uomId)
        if state == CardState.editMode {
            repository.update(dpProductCardModel)
            delegate.productUpdated()
        } else {
            repository.save(new: dpProductCardModel)
            delegate.add(new: productCard.productId)
        }
    }
    
    private func saveStatistic() {
        if let priceStr = itemPrice.text,
            let price = priceStr.numberFormatting(),
            price != 0.0 {
            
            guard productCard.productPrice != price  else {
                alert(title: "Спасибо", message: "Цена не поменялась😉. Круто!👍", okAction: {
                    self.close()
                })
                return
            }
            
            let dpStatModel = DPPriceStatisticModel(outletId: outletId,
                                                    productId: productCard.productId,
                                                    price: price, date: Date())
            repository.save(new: dpStatModel)
            delegate.productUpdated()
            self.close()
            
        } else {
            alert(title: "Спасибо", message: "Такую цену мы не можем сохранить😭. Но товар в базе и шоплисте😉", okAction: {
                self.close()
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// MARK: Picker
extension ItemCardNew: PickerControlDelegate {
    func choosen(id: Int32) {
        if pickerType == PickerType.category {
            productCard.categoryId = id
            for category in categories {
                if category.id == id {
                    
                    self.categoryButton.setTitle(category.name, for: .normal)
                    
                    
                    break
                }
            }
        } else {
            productCard.uomId = id
            self.uoms.forEach {
                if $0.id == id {
                    self.uomButton.setTitle($0.name, for: .normal)
                }
            }
        }
    }
}



extension ItemCardNew {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    
}
