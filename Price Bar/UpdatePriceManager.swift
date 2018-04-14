//
//  UpdatePriceManager.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


class UpdatePriceManager {
    
    var interactor: ShoplistInteractor!
    var vc: UIViewController!
    
    init(vc: UIViewController, interactor: ShoplistInteractor) {
        self.vc = vc
        self.interactor = interactor
    }
    
    func updatePrice(productId: String, outletId: String) {
        
        let vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
        self.vc.present(vc, animated: true)
        
        
        
    }
}
