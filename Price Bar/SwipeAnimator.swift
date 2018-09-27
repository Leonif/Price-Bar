//
//  SwipeAnimator.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/27/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class SwipeAnimator {
    
    private var constraits: [NSLayoutConstraint] = []
    private var swipeViewArea: UIView!
    private var buttonsHided: Bool = false
    var onAnimated: ((Bool) -> Void)?
    
    
    init(swipeViewArea: UIView) {
        self.swipeViewArea = swipeViewArea
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        rightSwipe.direction = .right
        swipeViewArea.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        leftSwipe.direction = .left
        swipeViewArea.addGestureRecognizer(leftSwipe)
    }
    
    func appendAnimated(constraints: [NSLayoutConstraint]) {
        self.constraits.append(contentsOf: constraints)
    }
    
    
    @objc
    func hideButtons(gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
            return
        }
        switch swipeGesture.direction {
        case .right:  self.shiftButton(hide: buttonsHided)
        case .left:   self.shiftButton(hide: buttonsHided)
        default: break
        }
        
        buttonsHided.toggle()
    }
    
    private func shiftButton(hide: Bool) {
        let shiftOfDirection: CGFloat = hide ? -1 : 1
        let movementDistance: CGFloat = 120
        
        let moveToRight: CGFloat = self.constraits[0].constant - shiftOfDirection * movementDistance
        let moveToLeft: CGFloat = self.constraits[1].constant - shiftOfDirection * movementDistance
        self.constraits[0].constant = moveToRight
        self.constraits[1].constant = moveToLeft
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: { 
                        self.swipeViewArea.layoutIfNeeded()
                        self.onAnimated?(self.buttonsHided)
                        
        })
    }
    
    
    
}
