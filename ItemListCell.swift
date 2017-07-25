//
//  ItemListCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemListCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemMinPriceLabel: UILabel!
    
    
    func configureCell(_ item: ShopItem) {
        itemNameLabel.text = item.name
        itemPriceLabel.text = item.price.asLocaleCurrency
        itemMinPriceLabel.text = "лучшая: \(item.minPrice.asLocaleCurrency)"
    }
    
}
