//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit


enum BorderSide {
    case left, right, top, bottom
}


class ShopItemCell: UITableViewCell, NibLoadableReusable {
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!

    @IBOutlet weak var quantityButton: UIButton!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    var onWeightDemand: ((ShopItemCell) -> Void)?
    var onCompareDemand: ((ShopItemCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onCompareHandler))
        
        self.priceView.addGestureRecognizer(gesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.topView.isHidden = false
        self.bottomView.isHidden = false
        self.leftView.isHidden = false
        self.rightView.isHidden = false
    }
    
    @objc
    func onCompareHandler() {
        self.onCompareDemand?(self)
    }

    @IBAction func changeQuantity(_ sender: UIButton) {
        self.onWeightDemand?(self)
    }
}
