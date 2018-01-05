//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ShopItemCellDelegate {
    func checkPressed(for item: ShopItem)
    func weightDemanded(cell: ShopItemCell)
}


class ShopItemCell: UITableViewCell {
    
    var item: ShopItem?
    
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var checkMarkBtn: UIButton!
    @IBOutlet weak var quantityButton: UIButton!
    
    
    var delegate: ShopItemCellDelegate?
    var weightList = [Double]()
    //var currentIndex = 0
    
    
    @IBAction func changeQuantity(_ sender: UIButton) {
        delegate?.weightDemanded(cell: self)
    }
    
}

// User react
extension ShopItemCell {
    @IBAction func checkPressed(_ sender: UIButton) {
        
        guard let item = self.item else {
            fatalError("Check pressed for not existed item")
        }
        
        self.item?.checked = !item.checked
        self.checkedState()
        self.delegate?.checkPressed(for: item)
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
    
    
    func configureCell(item: ShopItem) {
        
        self.item = item
        let s = item
        self.checkedState()
        
        nameItem.text = s.name
        priceItem.text = "\(s.price.asLocaleCurrency)"
        uomLabel.text = s.itemUom.name
        
        self.updateWeighOnCell(s.quantity, s.price)
        
    }
}






