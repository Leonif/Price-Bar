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
    func shoplist(updated shopListService: DataProvider)
    
}

class ShopListDataSource: NSObject, UITableViewDataSource {
   
    var shopListService: DataProvider!
    var cellDelegate: ShopItemCellDelegate?
    var delegate: ShopListDataSourceDelegate?
    
    
    init(delegate: ShopListDataSourceDelegate, cellDelegate: ShopItemCellDelegate, shopListService: DataProvider) {
        self.shopListService = shopListService
        self.cellDelegate = cellDelegate
        self.delegate = delegate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopListService.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            if let shp = shopListService.getItem(index: indexPath) {
                cell.configureCell(item: shp)
                cell.delegate = cellDelegate
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopListService.sectionCount
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopListService.headerString(for: section)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = shopListService.getItem(index: indexPath) {
                tableView.beginUpdates()
                
                CoreDataService.data.removeFromShopList(item)
                let sectionStatus = shopListService.remove(item: item)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                if sectionStatus == .sectionEmpty  {
                    let indexSet = IndexSet(integer: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                }
                tableView.endUpdates()
                delegate?.shoplist(updated: shopListService)
                
            }
        }
    }
    
    
}




