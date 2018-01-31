//
//  OutletCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class OutletCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var outletView: UIView!

    func configureCell(outlet: Outlet) {

        if outlet.distance > 600 {
            outletView.alpha = 0.5
        } else {
            outletView.alpha = 1
        }

        name.text = outlet.name
        let distance = outlet.distance > 1000 ? "\(outlet.distance/1000) км" : "\(outlet.distance) м"
        distanceLabel.text = distance
        address.text = outlet.address

    }

}
