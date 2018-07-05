//
//  BaseView.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol BaseView: class {
    func showLoading(with text: String)
    func hideLoading()
    func onError(with message: String)
    func close()
    
}

extension BaseView where Self: UIViewController {
    func showLoading(with text: String) {
        self.view.pb_startActivityIndicator(with: text)
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.view.pb_stopActivityIndicator()
        }
        
    }
    
    func onError(with message: String) {
        self.alert(message: message)
    }
}
