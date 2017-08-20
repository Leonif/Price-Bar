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
        if let item = object as? ShopItem {
            handle(for: item)
        }
        if let outlet = object as? Outlet  {//outlet came
            handle(for: outlet)
        } else if let scannedCode = object as? String {//scann came
            handle(for: scannedCode)
        }
        shopTableView.reloadData()
        totalLabel.update(value: shopList.total)
    }
    
    func handle(for item: ShopItem) {
        let deviceBase = CoreDataService.data
        let cloudBase = FirebaseService.data
        
        shopList.change(item)
        if !deviceBase.update(item) {
            deviceBase.save(item)
        }
        cloudBase.saveOrUpdate(item)
        
        deviceBase.savePrice(for: item)
        cloudBase.savePrice(for: item)
    }
    
    
    
    
    
    
    func handle(for outlet: Outlet) {
        let needToReload = launchedTimes == 1 || launchedTimes >= 10
        
        if needToReload {
            print("Refresh from cloud...")

            view.addSubview(refresh)
            refresh.center = self.view.center
            refresh.run()
            
            FirebaseService.data.loginToFirebase({
                self.shopList.synchronizeCloud {
                    self.loadShopList(for: outlet)
                    self.refresh.stop()
                    launchedTimes = 2
                }
            }, {
                fatalError("Error of login to FIrebase")
            })
        } else {
            print("Refresh from cloud DONT NEED... \(launchedTimes)")
            loadShopList(for: outlet)
        }
    }
    
    
    func loadShopList(for outlet: Outlet) {
        userOutlet = outlet
        outletNameButton.setTitle(userOutlet.name, for: .normal)
        outletAddressLabel.text = userOutlet.address
        shopList.pricesUpdate(by: userOutlet.id)
        
        if let shpLst = CoreDataService.data.loadShopList(outletId: userOutlet.id), !selfLoaded {
            shopList = shpLst
            totalLabel.update(value: shopList.total)
            selfLoaded = true
        }
        
    }
    
    
    
    func handle(for scannedCode: String) {
        var item: ShopItem!
        
        let deviceBase = CoreDataService.data
        let cloudBase = FirebaseService.data
        
        if let foundItem = deviceBase.getItem(by: scannedCode, and: userOutlet.id) {// exists on device
            item = foundItem
            handle(for: item)
        } else { //doesnt exist in coreData
            let itemCategory = deviceBase.defaultCategory // default category
            let itemUom = deviceBase.initUoms[0]
            
            item = ShopItem(id: scannedCode, name: "Неизвестно", quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, itemUom: itemUom, outletId: userOutlet.id, scanned: true, checked: false)
            
            //add to coredata and firebase
            cloudBase.saveOrUpdate(item)
            deviceBase.save(item)
            
            
        }
        //save price statistics
        deviceBase.savePrice(for: item)
        cloudBase.savePrice(for: item)
        
        deviceBase.saveToShopList(item)
        shopList.append(item)
        
        
    }
    
}
