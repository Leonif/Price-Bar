//
//  CustomViews.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 8/20/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

class RefreshView: UIView {
    var progressLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.text = "Waiting..."
        lbl.font = lbl.font.withSize(11)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let acInd = UIActivityIndicatorView()
        acInd.translatesAutoresizingMaskIntoConstraints = false
        return acInd
        
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //controlsSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        controlsSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func controlsSetup() {
        
        self.backgroundColor = UIColor.lightGray
        self.backgroundColor?.withAlphaComponent(0.7)
        
        self.layer.cornerRadius = 15
        
        self.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addSubview(progressLabel)
        progressLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8).isActive = true
        progressLabel.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
    
    func run() {
        //controlsSetup()
        activityIndicator.startAnimating()
    }
    
    func stop() {
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
    
}
