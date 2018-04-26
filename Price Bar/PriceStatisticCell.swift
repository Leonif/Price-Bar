//
//  PriceStatisticCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/28/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class PriceStatisticCell: UITableViewCell, NibLoadableReusable {
    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var outletAddress: UILabel!
    @IBOutlet weak var priceInfo: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var backView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        PriceBarStyles.grayBorderedRoundedView.apply(to: self.backView)
        
    }
    
    
}
