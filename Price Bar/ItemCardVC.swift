//
//  ItemCardVC.swift
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


enum CardState {
    case createMode, editMode
}



protocol ItemCardView: BaseView {
    func onCategoryChoosen(name: String)
    func onUomChoosen(name: String)
}


class ItemCardVC: UIViewController, ItemCardView {
    var presenter: ItemCardPresenter!
    var state: CardState!
    var pickerAdapter: PickerControl!
    
    var categories: [CategoryModelView] = []
    var uoms: [UomModelView] = []
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?


    var item: ShoplistItem?
    var barcode: String?
    var productCard: ProductCardViewEntity!
    
    
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
            PriceBarStyles.grayBorderedRounded.apply(to: $0)
        }
        
        [itemName, itemBrand, itemWeight, itemPrice].forEach {
            $0!.delegate = self
            self.addToolBar(textField: $0!)
        }
        
        
        
//        guard let uoms = repository.getUomList() else {
//            fatalError("Catgory list is empty")
//        }
//        self.uoms = uoms
//        self.cardOpenHandler()
        
        self.setupKeyboardObserver()
    }
    
    
    
    
    func setupKeyboardObserver() {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        
    }
    
    
//    private func cardOpenHandler() {
//        if let item = item {
//            state = CardState.editMode
//            self.productCard = ProductMapper.mapper(from: item)
//            updateUI(for: productCard)
//
//        }
//
//        if let barcode = self.barcode {
//            state = CardState.createMode
//            print("New product")
//            self.productCard = ProductMapper.mapper(from: barcode)
//            updateUI(for: productCard)
//        }
//
//        if let searchText = self.searchedItemName {
//            state = CardState.createMode
//            print("New product")
//            self.productCard = ProductMapper.mapper(for: searchText)
//            updateUI(for: productCard)
//
//        }
//    }
    
//    func updateUI(for productCard: ProductCardModelView) {
//        self.itemName.text = productCard.productName
//        self.itemPrice.text = "\(productCard.productPrice)"
//        self.itemBrand.text = productCard.brand
//        self.itemWeight.text = productCard.weightPerPiece
//
//        self.categoryButton.setTitle(productCard.categoryName, for: .normal)
//        self.uomButton.setTitle(productCard.uomName, for: .normal)
//    }
    
    @IBAction func categoryPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let label = categoryButton.titleLabel,
        let currentCategory = label.text  else { return }
        
        self.presenter.onCategoryPressed(currentCategory: currentCategory)
        
    }
    
    @IBAction func uomPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let label = self.uomButton.titleLabel,
            let currentUom = label.text  else { return }
        
        self.presenter.onUomPressed(currentUom: currentUom)
    }
    
    func onUomChoosen(name: String) {
        self.categoryButton.setTitle(name, for: .normal)
    }
    
    func onCategoryChoosen(name: String) {
        self.categoryButton.setTitle(name, for: .normal)
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
                self.alert(message: R.string.localizable.empty_product_name())
                return
        }
        self.saveProduct(with: name)
       
    }
    
    private func saveProduct(with name: String) {
        productCard.productName = name
        productCard.brand = itemBrand.text ?? ""
        productCard.weightPerPiece = itemWeight.text ?? ""
        
        
        
        let dpProductCardModel = DPUpdateProductModel(id: productCard.productId,
                                                      name: productCard.productName,
                                                      brand: productCard.brand,
                                                      weightPerPiece: productCard.weightPerPiece,
                                                      categoryId: productCard.categoryId,
                                                      uomId: productCard.uomId)
        self.presenter.onUpdateOrCreateProduct(product: dpProductCardModel)
    }
    
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: Picker
