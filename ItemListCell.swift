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
    
    

    func configureCell(_ item: ItemListModelView) {
        itemNameLabel.text = item.product
        self.itemCategoryLabel.text = item.categoryName
        itemPriceLabel.text = "UAH\n\(item.currentPrice)"
        
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
        cellView.layer.cornerRadius = cellView.frame.height / 2


    }

}
