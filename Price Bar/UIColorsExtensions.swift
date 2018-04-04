//
//  UIColorsExtensions.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/1/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


public enum Color {
    static var tomato: UIColor = UIColor.simpleColor(red: 233.0, green: 79.0, blue: 21.0, alpha: 1.0)
    static var mango: UIColor = UIColor.simpleColor(red: 255.0, green: 146.0, blue: 46.0, alpha: 1.0)
    static var darkGray: UIColor = UIColor.simpleColor(red: 151, green: 151, blue: 151, alpha: 1.0)
    static var gray: UIColor = UIColor.simpleColor(red: 216, green: 216, blue: 216, alpha: 1.0)
}


extension UIColor {
    
    static func simpleColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
        
    }
    
    
}




