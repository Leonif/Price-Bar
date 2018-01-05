//
//  Extensions.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/4/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit



extension UIViewController {
    
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}



// Activity Indicator
extension UIView {
    
    private var activityIndicatorTag: Int { return 999998 }
    private var activityBackgroundTag: Int { return 999997 }
    
    public func pb_startActivityIndicator(with title: String){
        startCustomActivityIndicator(with: title, location: self.center)
    }
    
    func pb_stopActivityIndicator() {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let views = window.subviews
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, animations: {
                
                for v in views {
                    if let activityIndicator = v.subviews.filter({ $0.tag == self.activityIndicatorTag }).first as? UIActivityIndicatorView {
                        
                        
                        guard let superV = activityIndicator.superview else {
                            fatalError("superview if indicator is not found")
                        }
                        
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        
                        superV.removeFromSuperview()
                        break
                        
                    }
                }
            })
        }
    }
    
    
    
    
    func startCustomActivityIndicator(with title: String, style: UIActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.white, location: CGPoint?) {
        let locationOnView = location ?? self.center
        DispatchQueue.main.async {
            let backgroundView = UIView(frame: self.frame)
            self.setupLabel(on: backgroundView, title: title, and: locationOnView)
            self.setupIndicator(on: backgroundView, with: style, and: location)
            self.show(backgroundView)
            
        }
    }
    func startCustomActivityIndicator(style: UIActivityIndicatorViewStyle = UIActivityIndicatorViewStyle.white, location: CGPoint?) {
        
        //let locationOnView = location ?? self.center
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.width
        
        DispatchQueue.main.async {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            self.setupIndicator(on: backgroundView, with: style, and: location)
            self.show(backgroundView)
        }
    }
    
    
    
    
    
    private func setupIndicator(on backgroundView: UIView, with style: UIActivityIndicatorViewStyle, and location: CGPoint?) {
        
        let locationOnView = location ?? self.center
        
        
        backgroundView.tag = self.activityBackgroundTag
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicator.tag = self.activityIndicatorTag
        activityIndicator.center = locationOnView
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        backgroundView.addSubview(activityIndicator)
        
        
        
    }
    
    private func setupLabel(on view: UIView, title: String, and location: CGPoint) {
        
        let width = UIScreen.main.bounds.width
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 100))
        titleLabel.textColor = .white
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.center = location
        let centerY = titleLabel.center.y
        titleLabel.center.y = centerY + 32
        view.addSubview(titleLabel)
        
    }
    
    func show(_ indicatorView: UIView) {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        indicatorView.backgroundColor = .clear
        
        window.addSubview(indicatorView)
        UIView.animate(withDuration: 0.8, animations: {
            indicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        })
    }
    
    func obscure() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        self.backgroundColor = .clear
        
        window.addSubview(self)
        UIView.animate(withDuration: 0.8, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        })
    }
    
    
    
    
}

