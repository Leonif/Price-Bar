//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ShopItemCell: UITableViewCell {
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!

    @IBOutlet weak var quantityButton: UIButton!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var cellView: UIView!
    
    var onWeightDemand: ((ShopItemCell) -> Void)?
    var onCompareDemand: ((ShopItemCell) -> Void)?
    


    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onCompareHandler))
        
        self.priceView.addGestureRecognizer(gesture)
    }
    
    @objc
    func onCompareHandler() {
        self.onCompareDemand?(self)
    }
    

    @IBAction func changeQuantity(_ sender: UIButton) {
        self.onWeightDemand?(self)
    }
}
