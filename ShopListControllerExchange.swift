//
//  Exchange.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation

protocol Exchange {
    func objectExchange(object: Any)
}

//MARK: Handlers based Exchange protocol
extension ShopListController: Exchange {
    
    func objectExchange(object: Any) {
        if let item = object as? ShopItem {
            shopList.change(item)
        }
        if let outlet = object as? Outlet  {//outlet came
            
            handle(for: outlet)
        
        } else if let scannedCode = object as? String {//scann came
            handle(for: scannedCode)
            
        }
        shopTableView.reloadData()
        totalLabel.update(value: shopList.total)
    }
    
    
    func handle(for outlet: Outlet) {
        
        
        let needToReload = true //= launchedTimes == 1 || launchedTimes > 10
        
        if needToReload {
            print("Refresh from cloud...")
            
            FirebaseService.data.loginToFirebase({ 
                self.shopList.reloadDBFromCloud {
                    //self.shopList.reloadDataFromCoreData(for: outlet.id)
                    self.loadShopList(for: outlet)
                }
            }, {
                fatalError("Error of login to FIrebase")
                
            })
            
        } else {
            print("Refresh from cloud DONT NEED...")
            //shopList.reloadDataFromCoreData(for: userOutlet.id)
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
        let item: ShopItem!
        if let it = CoreDataService.data.getItem(by: scannedCode, and: userOutlet.id) {
            item = it
        } else {
            
            let itemCategory = CoreDataService.data.initCategories[0]
            let itemUom = CoreDataService.data.initUoms[0]
            
            item = ShopItem(id: scannedCode, name: "Неизвестно", quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, itemUom: itemUom, outletId: userOutlet.id, scanned: true, checked: false)
        }
        shopList.append(item: item)
        print("From Exchange addToShopList")
        CoreDataService.data.addToShopListAndSaveStatistics(item)
        
    }
    
}
