//
//  CountingLabel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/11/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit



class CountingLabel: UILabel {

    public var updateBlock: ((_ currentPercanage: Float) -> Void)? = nil
    
    let counterVelocity: Float = 3.0 // ˆ3
    
    enum CounterType {
        case Int, Float
    }
    
    enum AnimationType {
        case Linear // f(x) = x
        case EaseIn // f(x) = xˆ3
        case EaseOut // f(x) = (1 - x)ˆ3
    }

    var currentCounterValue: Float {
        if progress >= duration {
            return endNumber
        }
        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)
        updateBlock?(percentage)
        
        return startNumber + (update * (endNumber - startNumber))
    }
    
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!
    
    var timer: Timer?
    
    
    var counterType: CounterType!
    var animationType: AnimationType!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func count(from fromValue: Float, to toValue: Float, with duration: TimeInterval, and animationType: AnimationType, and counterType: CounterType) {
        
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.counterType = counterType
        self.animationType = animationType
        self.progress = 0.0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        
        invalidateTimer()
        if duration == 0 {
            updateText(with: toValue)
            return
        }
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
        
    }
    
    @objc
    func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= duration {
            invalidateTimer()
            progress = duration
        }
        
        updateText(with: currentCounterValue)
        
    }
    
    func updateText(with value: Float) {
        switch counterType! {
        case .Int:
            self.text = "\(Int(value))"
        case .Float:
            self.text = String(format: "%.2f", value)
        }
        
    }
    
    
    func updateCounter(counterValue: Float) -> Float {
        
        switch animationType! {
        case .Linear:
            return counterValue
        case .EaseIn:
            return powf(counterValue, counterVelocity)
        case .EaseOut:
            return 1.0 - powf(1.0 - counterValue, counterVelocity)
        }
        
    }
    
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
}
