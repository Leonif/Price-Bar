//
//  GoodTextField.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class GoodTextField: UITextField {

    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10.0, dy: 5.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10.0, dy: 5.0)
    }
    

}
