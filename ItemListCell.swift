//
//  ItemListCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemListCell: UITableViewCell, NibLoadableReusable {
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        PriceBarStyles.grayBorderedRounded.apply(to: self.backView)
        self.backgroundColor = .clear
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.itemPriceLabel.textColor = Color.havelockBlue
        
    }

    func configureCell(_ item: ItemListViewEntity) {
        itemNameLabel.text = item.fullName
        self.itemCategoryLabel.text = item.categoryName
        itemPriceLabel.text = "UAH\n\(item.currentPrice)"
        if item.currentPrice == 0 {
            self.itemPriceLabel.text = "No price"
            self.itemPriceLabel.textColor = Color.petiteOrchid
        }
        
    }

}
