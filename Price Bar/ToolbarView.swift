//
//  ToolbarView.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/6/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


class ToolBarView: UIView {
    
    let doneButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        btn.setTitle("Done", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()
    let cancelButton: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.systemGray
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.systemGray
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.addSubview(doneButton)
        self.addSubview(cancelButton)
        
        let margin = self.layoutMarginsGuide
        
        cancelButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        
    }
    
}
