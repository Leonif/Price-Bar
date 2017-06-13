//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ShopItemCell: UITableViewCell {
    
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var quantityItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    
    @IBOutlet weak var quantitySlider: UISlider!
    

    func configureCell(item: ShopItem) {
        
        let s = item
        
        nameItem.text = s.name
        priceItem.text = "\(s.price.asLocaleCurrency)"
        quantityItem.text = String(format:"%.2f", s.quantity)
        uomLabel.text = s.uom.uom
        quantitySlider.value = Float(s.quantity)
        totalItem.text = s.total.asLocaleCurrency
        
    }

    
    
}
