//
//  Exchange.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

extension ShopListController: ScannerDelegate {
    func scanned(barcode: String) {
        print(barcode)
        if let product: DPProductModel = dataProvider.getItem(with: barcode, and: userOutlet.id) {
            addItemToShopList(product)
        } else {
            //self.barcode = barcode
            self.performSegue(withIdentifier: "scannedNewProduct", sender: barcode)
        }
        
    }
}


extension ShopListController: ItemListVCDelegate {
    func itemChoosen(productId: String) {
        guard let product: DPProductModel = dataProvider.getItem(with: productId, and: userOutlet.id) else {
            fatalError("product is not found")
        }
        addItemToShopList(product)
    }
    func addItemToShopList(_ product: DPProductModel) {
        let shopListItem: DPShoplistItemModel = ProductMapper.mapper(from: product, and: userOutlet.id)
        
        let result = dataProvider.saveToShopList(new: shopListItem)
        switch result {
        case .success:
            self.shopTableView.reloadData()
            self.totalLabel.update(value: dataProvider.total)
        case let .failure(error):
            alert(title: "Хмм", message: error.message)
        }
    }
}


extension ShopListController: OutletVCDelegate {
    func choosen(outlet: Outlet) {
        userOutlet = outlet
        
    }
}

extension ShopListController: ItemCardVCDelegate {
    func add(new productId: String) {
        print(productId)
        
        guard let product: DPProductModel = dataProvider.getItem(with: productId, and: userOutlet.id) else {
            fatalError("product is not found")
        }
        addItemToShopList(product)
    }
    
    func updated(status: Bool) {
        guard status == true else {
            return
        }
        dataProvider.loadShopList(for: userOutlet.id)
        totalLabel.update(value: dataProvider.total)
        shopTableView.reloadData()
    }
}
