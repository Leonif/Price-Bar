//
//  OutletCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class OutletCell: UITableViewCell {

    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var outletAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var outletView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.outletView.layer.cornerRadius = 5.0
        self.distanceView.layer.cornerRadius = self.distanceView.frame.width / 2
        self.distanceView.layer.borderColor = UIColor.white.cgColor
        self.distanceView.layer.borderWidth = 2.0
        
    }
    
}
