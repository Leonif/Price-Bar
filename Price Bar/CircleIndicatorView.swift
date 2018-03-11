//
//  CircleIndicatorView.swift
//  TRIBU
//
//  Created by LEONID NIFANTIJEV on 2/14/18.
//  Copyright © 2018 Synergetica. All rights reserved.
//

import Foundation
import UIKit

class CircleIndicator: UIView {
    private let shapeLayer = CAShapeLayer()
    private let indicator: UILabel = {
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        lbl.textAlignment = .center
        lbl.textColor = UIColor.black
        return lbl
    }()
    private var circlePath: UIBezierPath!
    
    private var trackColor: UIColor = UIColor.lightGray
    private var inidicatorColor: UIColor = UIColor.red
    private var lineWidth: CGFloat = 2
    
    private var highGoal: CGFloat = 100
    private var currentGoal: CGFloat = 50
    private var viewCenter: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        circlePath = UIBezierPath(arcCenter: .zero,
                                  radius: frame.size.width / 2 - 8,
                                  startAngle: 0,
                                  endAngle: CGFloat.pi * 2,
                                  clockwise: true)
        let size = frame.size
        viewCenter = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    public func decorate(colors: (track: UIColor, indicator: UIColor), lineWidth: CGFloat) {
        trackColor = colors.track
        inidicatorColor = colors.indicator
        self.lineWidth = lineWidth
    }
    public func startShow(for indicators: (current: Double, max: Double)) {
        currentGoal = CGFloat(indicators.current)
        highGoal = CGFloat(indicators.max)
        buildTrack()
        buildIndicator()
        animate()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildTrack() {
        let trackLayer = CAShapeLayer()
        trackLayer.path = circlePath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.position = viewCenter
        self.layer.addSublayer(trackLayer)
    }
    
    private func buildIndicator() {
        indicator.center = viewCenter
        indicator.text = "\(Int(currentGoal))"
        self.addSubview(indicator)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = inidicatorColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.position = viewCenter
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        
        self.layer.addSublayer(shapeLayer)
    }
    fileprivate func animate() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = CGFloat(currentGoal)/CGFloat(highGoal)
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "animId")
    }
    
    
}
