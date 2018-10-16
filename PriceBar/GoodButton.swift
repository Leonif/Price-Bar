//
//  GoodButton.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class GoodButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
//        self.castShadow()
        
//        self.roundingEdges()
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        UIView.animate(withDuration: 0.6,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.6) {
                            self.transform = CGAffineTransform.identity
                        }
        })
    }
}
