//
//  FlexibleStyle.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/21/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

precedencegroup Composition {
    associativity: left
}


infix operator <+: Composition

typealias Style<Type: UIView> = (Type) -> Void

func <+ <Type: UIView>(lhs: @escaping Style<Type>, rhs:  @escaping Style<Type>) -> Style<Type> {
    return {
        lhs($0)
        rhs($0)
    }
}


func cornerRadius(_ radius: CGFloat) -> (UIView) -> Void {
    return { $0.layer.cornerRadius = radius }
}

func borderWidth(_ borderWidth: CGFloat) -> (UIView) -> Void {
    return { $0.layer.borderWidth = borderWidth }
}

func borderColor(_ borderColor: UIColor) -> (UIView) -> Void {
    return { $0.layer.borderColor = borderColor.cgColor }
}

func shadowColor(_ shadowColor: UIColor) -> (UIView) -> Void {
    return { $0.layer.shadowColor = shadowColor.cgColor }
}

func shadowOpacity(_ shadowOpacity: Float) -> (UIView) -> Void {
    return { $0.layer.shadowOpacity = shadowOpacity }
}


func shadowRadius(_ shadowRadius: CGFloat) -> (UIView) -> Void {
    return { $0.layer.shadowRadius = shadowRadius }
}

func shadowOffset(_ shadowOffset: CGSize) -> (UIView) -> Void {
    return { $0.layer.shadowOffset = shadowOffset }
}



let usualCornerRadius = cornerRadius(8)
let usualBorderWidth = cornerRadius(2)
let dustyGrayBorder = borderColor(Color.dustyGray)


let usualShadowColor = shadowColor(UIColor.black)
let usualShadowOpacity = shadowOpacity(0.8)
let usualShadowRadius = shadowRadius(5.0)
let usualShadowOffset = shadowOffset(CGSize(width: 1.0, height: 1.0))

let usualShadow = usualShadowColor <+ usualShadowOpacity <+ usualShadowRadius <+ usualShadowOffset

// MARK: Style presets
let grayBorderedRounded = usualCornerRadius <+ usualBorderColor <+ dustyGrayBorder
let grayBorderedRoundedWithShadow = grayBorderedRounded <+ usualShadow
