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
            self.interactor.getPriceStatistics(for: productId, completion: { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case let .success(statistic):
                    let vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
                    vc.price = self.interactor.getPrice(for: productId, in: outletId)
                    vc.dataSource = statistic
                    vc.productName = self.interactor.getProductName(for: productId)
                    vc.onSavePrice = { [weak self] price in
                        guard let `self` = self else { return }
                        self.interactor.updatePrice(for: productId, price: price, outletId: outletId)
                        self.interactor.reloadProducts(outletId: outletId)
                    }
                    self.vc.present(vc, animated: true)
                case let .failure(error):
                    self.vc.alert(message: error.message)
                }
            })
    }
}
