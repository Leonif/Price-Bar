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
            userOutlet = outlet
            outletNameButton.setTitle(userOutlet.name, for: .normal)
            outletAddressLabel.text = userOutlet.address
            shopList.pricesUpdate(by: userOutlet.id)
            if let shpLst = CoreDataService.data.loadShopList(outletId: userOutlet.id), !selfLoaded {
                shopList = shpLst
                totalLabel.update(value: shopList.total)
                selfLoaded = true
            }
        } else if let code = object as? String {//scann came
            //print(code)
            let item: ShopItem!
            if let it = CoreDataService.data.getItem(by: code, and: userOutlet.id) {
                item = it
            } else {
                
                let itemCategory = CoreDataService.data.initCategories[0]
                
                item = ShopItem(id: code, name: "Неизвестно", quantity: 1.0, minPrice: 0.0, price: 0.0, itemCategory: itemCategory, uom: ShopItemUom(), outletId: userOutlet.id, scanned: true, checked: false)
            }
            shopList.append(item: item)
            print("From Exchange addToShopList")
            CoreDataService.data.addToShopListAndSaveStatistics(item)
        }
        shopTableView.reloadData()
        totalLabel.update(value: shopList.total)
    }
    
}
