//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ShopItemCell: UITableViewCell {
    enum CheckMark: String {
        case check = "check"
        case uncheck = "uncheck"
    }

    var onWeightDemand: ((ShopItemCell) -> Void)?
    var onCompareDemand: ((ShopItemCell) -> Void)?
    
    var item: DPShoplistItemModel?

    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var checkMarkBtn: UIButton!
    @IBOutlet weak var quantityButton: UIButton!


    var weightList = [Double]()

    @IBAction func changeQuantity(_ sender: UIButton) {
        onWeightDemand?(self)
    }
}

// User react
extension ShopItemCell {
    @IBAction func checkPressed(_ sender: UIButton) {
        self.onCompareDemand?(self)
    }

    func updateWeighOnCell(_ weight: Double, _ price: Double) {

        let total = weight * price

        self.quantityButton.setTitle(String(format:"%.2f", weight), for: .normal)
        self.totalItem.text = total.asLocaleCurrency
    }

    func checkedState() {
        guard let item = self.item else {
            fatalError("Check state for not existed item")
        }
        let checkAlpha = CGFloat(item.checked ? 0.5 : 1)
        self.contentView.alpha = checkAlpha
        let imageStr = item.checked ? CheckMark.check.rawValue : CheckMark.uncheck.rawValue
        self.checkMarkBtn.setImage(UIImage(named: imageStr), for: .normal)
    }

    func configureCell(item: DPShoplistItemModel) {

        self.item = item
        self.checkedState()

        nameItem.text = item.productName
        priceItem.text = "\(item.productPrice.asLocaleCurrency)"
        uomLabel.text = item.productUom

        self.updateWeighOnCell(item.quantity, item.productPrice)
    }
}
