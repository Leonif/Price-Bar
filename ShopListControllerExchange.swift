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

//MARK: Handlers based Exchange protocol
extension ShopListController: Exchange {
    
    func objectExchange(object: Any) {
        if let item = object as? ShopItem { // card save
            self.handle(for: item)
        }
        if let outlet = object as? Outlet  {//outlet came
            //self.handle(for: outlet)
        }
        if let scannedCode = object as? String {//scann came
            self.handle(for: scannedCode)
        }
        self.dataSource?.shopListService = shopListService
        self.shopTableView.reloadData()
        self.totalLabel.update(value: shopListService.total)
    }
    
    func handle(for item: ShopItem) {
        let deviceBase = CoreDataService.data
        let cloudBase = FirebaseService.data
        
        if !self.shopListService.change(item) {
            
            self.shopListService.append(item)
            deviceBase.saveToShopList(item)
        } else {
            self.shopListService.updateSections()
        }
        if !deviceBase.update(item) {
            deviceBase.save(item)
        }
        cloudBase.saveOrUpdate(item)
        
//        deviceBase.savePrice(for: item)
//        cloudBase.savePrice(for: item)
    }
    
    
    
    
    
    
//    func handle(for outlet: Outlet) {
//        let needToReload = launchedTimes == 1 || launchedTimes >= 10
//        
//        if needToReload { // from cloud
//            print("Refresh from cloud...")
//            self.view.pb_startActivityIndicator(with: "Синхронизация с облаком. Пожалуйста подождите...")
//            
//            FirebaseService.data.loginToFirebase({
//                self.shopListService.synchronizeCloud {
//                    self.loadShopList(for: outlet)
//                    self.view.pb_stopActivityIndicator()
//                    launchedTimes = 2
//                }
//            }, {
//                fatalError("Error of login to FIrebase")
//            })
//        } else {// load from coredata
//            self.shopListService.synchronizeDevice()
//            print("Refresh from cloud DONT NEED... \(launchedTimes)")
//            self.loadShopList(for: outlet)
//        }
//    }
    
    
    func loadShopList(for outlet: Outlet) {
        userOutlet = outlet
        outletNameButton.setTitle(userOutlet.name, for: .normal)
        outletAddressLabel.text = userOutlet.address
        shopListService.pricesUpdate(by: userOutlet.id)
        
        if let shopListService = CoreDataService.data.loadShopList(outletId: userOutlet.id)/*, !selfLoaded*/ {
            self.shopListService = shopListService
            dataSource?.shopListService = shopListService
            self.shopTableView.reloadData()
            totalLabel.update(value: shopListService.total)
//            ..selfLoaded = true
        }
        
    }
    
    
    
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
//        deviceBase.savePrice(for: item)
//        cloudBase.savePrice(for: item)
        
        deviceBase.saveToShopList(item)
        shopListService.append(item)
        
        
    }
    
}
