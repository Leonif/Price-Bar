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
    static var havelockBlue: UIColor = UIColor(rgb: 0x4A90E2)
    static var atlantis: UIColor = UIColor.simpleColor(red: 131, green: 200, blue: 60)
    static var feijoaGreen: UIColor = UIColor(rgb: 0xB0DB84)
}


extension UIColor {
    static func simpleColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}




