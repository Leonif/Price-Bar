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
    


    func configureCell(outlet: Outlet) {
        
        name.text = outlet.name
        address.text = outlet.address + "(\(outlet.distance))"
        
        
        
        
    }
    
}
