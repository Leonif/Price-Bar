//
//  Exchange.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol Exchange {
    func objectExchange(object: Any)
}



extension ShopListController: ItemListVCDelegate {
    func itemChoosen(productId: String) {
        guard let product = dataProvider.getItem(with: productId, and: userOutlet.id) else {
            return
        }
        let categoryName = dataProvider.getCategoryName(category: product.categoryId)
        let shopListItem = ShoplistItemModel(productId: product.id,
                                             productName: product.name,
                                             productCategory: categoryName, quantity: 1.0, checked: false)
        
        
        dataProvider.saveToShopList(new: shopListItem)
        
//        guard let stat = ItemStatistic(productId: item.id,
//                                       price: item.price,
//                                       outletId: userOutlet.id,
//                                       date: Date()) else {
//                                        alert(title: "Opps", message: "Цена на товар не записана :(")
//                                        return
//        }
//        dataProvider.save(new: stat)
        self.totalLabel.update(value: dataProvider.total)
    }
}


extension ShopListController: OutletVCDelegate {
    func choosen(outlet: Outlet) {
        userOutlet = outlet
        
    }
}





//MARK: Handlers based Exchange protocol
extension ShopListController: Exchange {
    
    func objectExchange(object: Any) {
//        if let item = object as? ShopItem { // card save
//            self.handle(for: item)
//        }
//
//        if let scannedCode = object as? String {//scann came
//            self.handle(for: scannedCode)
//        }
//        self.dataSource?.dataProvider = dataProvider
//        self.shopTableView.reloadData()
//        self.totalLabel.update(value: dataProvider.total)
    }
    
    
    
    
    
//    func loadShopList(for outlet: Outlet) {
//        userOutlet = outlet
//        outletNameButton.setTitle(userOutlet.name, for: .normal)
//        outletAddressLabel.text = userOutlet.address
//        dataProvider.pricesUpdate(by: userOutlet.id)
//        
//        if let dataProvider = CoreDataService.data.loadShopList(outletId: userOutlet.id)/*, !selfLoaded*/ {
//            self.dataProvider = dataProvider
//            dataSource?.shopListService = dataProvider
//            self.shopTableView.reloadData()
//            totalLabel.update(value: dataProvider.total)
//        }
//        
//    }
    
    
    
    func handle(for scannedCode: String) {
        var item: ShopItem!
        
        let deviceBase = CoreDataService.data
        let cloudBase = FirebaseService.data
        
        if let foundItem = deviceBase.getItem(by: scannedCode, and: userOutlet.id) {// exists on device
            item = foundItem
            //handle(for: item)
        } else { //doesnt exist in coreData
            let itemCategory = deviceBase.defaultCategory! // default category
            let itemUom = deviceBase.initUoms[0]
            
            item = ShopItem(id: scannedCode, name: "Неизвестно", quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, itemUom: itemUom, outletId: userOutlet.id, scanned: true, checked: false)
            
            //add to coredata and firebase
            cloudBase.saveOrUpdate(item)
            deviceBase.save(item)
            
            
        }
        //save price statistics
        deviceBase.saveToShopList(item)
        dataProvider.append(item)
        
        
    }
    
}
