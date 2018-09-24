//
//  HeaderView.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/5/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView, NibLoadableReusable {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        grayBorderedRounded(self.view)
    }
    
    func configure(with text: String) {
        self.categoryLabel.text = text
    }
}
