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
    
    func configureCell(_ item: ItemListModelView) {
        let checkAlpha = CGFloat(item.currentPrice == 0 ? 0.5 : 1)
        self.contentView.alpha = checkAlpha
        itemNameLabel.text = item.product
        itemPriceLabel.text = item.currentPrice.asLocaleCurrency
        itemMinPriceLabel.text = "лучшая: \(item.minPrice.asLocaleCurrency)"
    }
    
}

class AddCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        cellView.layer.cornerRadius = cellView.frame.height/2
        cellView.backgroundColor = .red
    }
    
}

