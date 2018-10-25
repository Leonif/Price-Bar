//
//  AddCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/28/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class AddCell: UITableViewCell, NibLoadableReusable {
    @IBOutlet weak var cellView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear
        PriceBarStyles.blueBorderedRounded.apply(to: self.cellView)

    }

}
