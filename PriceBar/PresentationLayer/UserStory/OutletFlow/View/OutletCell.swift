//
//  OutletCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class OutletCell: UITableViewCell, NibLoadableReusable {

    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var outletAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var outletView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        PriceBarStyles.grayBorderedRounded.apply(to: outletView)
    }
    
    
    func bind(outlet: OutletViewItem) {
        
        if outlet.distance > 600 {
            //cell.distanceView.backgroundColor = UIColor.lightGray
        } else {
            //cell.distanceView.backgroundColor = Color.neonCarrot
        }
        
        self.outletName.text = outlet.name
        let km = R.string.localizable.outlet_list_km("\(Int(outlet.distance/1000))")
        let m = R.string.localizable.outlet_list_m("\(Int(outlet.distance))")
        
        let distance = outlet.distance > 1000 ? km : m
        
        self.distanceLabel.text = distance
        self.outletAddress.text = outlet.address
    }
    
}
