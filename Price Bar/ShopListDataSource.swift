//
//  ShopListDataSource.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/5/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol ShopListDataSourceDelegate {
    func checkPressed(for item: ShopItem)
    func selectedWeight(for item: ShopItem, weight: Double)
    func shoplist(updated shopModel: ShopListModel)
    
}

class ShopListDataSource: NSObject, UITableViewDataSource {
   
    var shopModel: ShopListModel!
    var delegate: ShopListDataSourceDelegate?
    
    
    init(shopModel: ShopListModel) {
        self.shopModel = shopModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopModel.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            if let shp = shopModel.getItem(index: indexPath) {
                cell.configureCell(item: shp)
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopModel.sectionCount
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopModel.headerString(for: section)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = shopModel.getItem(index: indexPath) {
                tableView.beginUpdates()
                
                CoreDataService.data.removeFromShopList(item)
                let sectionStatus = shopModel.remove(item: item)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                if sectionStatus == .sectionEmpty  {
                    let indexSet = IndexSet(integer: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                }
                tableView.endUpdates()
                delegate?.shoplist(updated: shopModel)
                
            }
        }
    }
    
    
}



//MARK: Cell handlers
extension ShopListDataSource: ShopItemCellDelegate {
    func checkPressed(for item: ShopItem) {
        delegate?.checkPressed(for: item)
    }
    func selectedWeight(for item: ShopItem, weight: Double) {
        
        delegate?.selectedWeight(for: item, weight: weight)
    }
    
}
