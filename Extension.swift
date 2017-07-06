//
//  Extension.swift
//  devslopes-social
//
//  Created by Leonid Nifantyev on 7/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    
    func animateViewMoving (up:Bool, moveValue :CGFloat, view: UIView){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
}
