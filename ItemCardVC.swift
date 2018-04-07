//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ItemCardVCDelegate: class {
    func productUpdated()
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

    var categories: [CategoryModelView] = []
    var uoms: [UomModelView] = []
    var pickerType: PickerType?
    var outletId: String!
    var searchedItemName: String?
    weak var repository: Repository!

    @IBOutlet weak var commonPickerView: UIPickerView!
    var item: DPShoplistItemModel?
    var barcode: String?
    var productCard: ProductCardModelView!

    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!

    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var uomButton: UIButton!

    weak var delegate: ItemCardVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        initController()
        cardOpenHandler()
    }

    func initController() {
        itemTitle.delegate = self
        itemPrice.delegate = self

        //load categories
        guard let dpCategoryList = repository.getCategoryList() else {
            fatalError("Category list is empty")
        }

        self.categories = dpCategoryList.map { CategoryMapper.mapper(from: $0) }

        guard let uoms = repository.getUomList() else {
            fatalError("Catgory list is empty")
        }
        self.uoms = uoms
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
        itemTitle.text = productCard.productName
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

    @IBAction func backPressed(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func savePressed(_ sender: Any) {

        guard
            let name = itemTitle.text,
            !name.isEmpty
            else {
                alert(title: "Агинь", message: "Заполните название товара 👿 !!!")
                return
        }
        saveProduct(with: name)
        saveStatistic()
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

    
    func formmatter(_ priceString: String) -> Double? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        if let number = formatter.number(from: priceString) {
            return Double(truncating: number)
        } else  {
            formatter.decimalSeparator = ","
            if let number = formatter.number(from: priceString) {
                return Double(truncating: number)
            }
        }
        return nil
    }

    
    private func saveStatistic() {
        if let priceStr = itemPrice.text,
            let price = formmatter(priceStr),
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
}

// MARK: Picker
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
