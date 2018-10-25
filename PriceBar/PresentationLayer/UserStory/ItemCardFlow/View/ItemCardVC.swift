//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

protocol ItemCardView: BaseView {
    func onCategoryChoosen(name: String)
    func onUomChoosen(name: String)
    func onCardInfoUpdated(productCard: ProductCardEntity)
}

class ItemCardVC: UIViewController, ItemCardView {
    var presenter: ItemCardPresenter!
    var categories: [CategoryViewItem] = []
    var uoms: [UomViewItem] = []
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?

    var productId: String?

    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemBrand: UITextField!
    @IBOutlet weak var itemWeight: UITextField!
    @IBOutlet weak var uomButton: UIButton!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var productCard: ProductCardEntity?

    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!

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
        self.setupKeyboardObserver()
        self.presenter.onGetCardInfo(productId: productId ?? "", outletId: outletId)
    }

    func setupKeyboardObserver() {
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }

    func onCardInfoUpdated(productCard: ProductCardEntity) {
        self.itemName.text = productCard.productName
        self.itemPrice.text = "\(productCard.newPrice)"

        self.itemBrand.text = productCard.brand
        self.itemWeight.text = productCard.weightPerPiece

        self.categoryButton.setTitle(productCard.categoryName, for: .normal)
        self.uomButton.setTitle(productCard.uomName, for: .normal)

        self.productCard = productCard
    }

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
        self.uomButton.setTitle(name, for: .normal)
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
        guard let oldPrice = self.productCard?.oldPrice else {
            self.onError(with: R.string.localizable.error_something_went_wrong())
            return

        }

        let productCard = ProductCardEntity(productId: productId ?? "",
                                                productName: itemName.text ?? "",
                                                brand: itemBrand.text ?? "",
                                                weightPerPiece: itemWeight.text ?? "",
                                                categoryName: categoryButton.titleLabel?.text ?? "",
                                                newPrice: itemPrice.text ?? "",
                                                oldPrice: oldPrice,
                                                uomName: uomButton.titleLabel?.text ?? "")

        self.presenter.onUpdateOrCreateProduct(productCard: productCard, for: outletId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}
