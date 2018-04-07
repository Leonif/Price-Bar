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
    static var pomegranate: UIColor = UIColor.simpleColor(red: 233.0, green: 79.0, blue: 21.0)
    static var neonCarrot: UIColor = UIColor.simpleColor(red: 255.0, green: 146.0, blue: 46.0)
    static var dustyGray: UIColor = UIColor.simpleColor(red: 151, green: 151, blue: 151)
    static var alto: UIColor = UIColor.simpleColor(red: 216, green: 216, blue: 216)
    static var petiteOrchid: UIColor = UIColor.simpleColor(red: 223, green: 142.0, blue: 142.0)
    static var jaggedIce: UIColor = UIColor.simpleColor(red: 200, green: 231, blue: 238)
    static var atlantis: UIColor = UIColor.simpleColor(red: 131, green: 200, blue: 60)
}


extension UIColor {
    
    static func simpleColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
        
    }
    
    
}




