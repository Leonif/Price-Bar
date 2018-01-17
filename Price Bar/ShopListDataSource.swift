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
   
    var dataProvider: DataProvider!
    var cellDelegate: ShopItemCellDelegate?
    var delegate: ShopListDataSourceDelegate?
    
    
    init(delegate: ShopListDataSourceDelegate, cellDelegate: ShopItemCellDelegate, dataProvider: DataProvider) {
        self.dataProvider = dataProvider
        self.cellDelegate = cellDelegate
        self.delegate = delegate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell  else {
            return UITableViewCell()
        }
        
        guard let shp = dataProvider.getItem(index: indexPath) else {
            return UITableViewCell()
        }
        
        cell.configureCell(item: shp)
        cell.delegate = cellDelegate
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.sectionCount
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataProvider.headerString(for: section)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = dataProvider.getItem(index: indexPath) {
                tableView.beginUpdates()
                
                
                dataProvider.remove(item: item)
                let itemCountInSection = dataProvider.rowsIn(indexPath.section)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                if itemCountInSection == 0  {
                    let indexSet = IndexSet(integer: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                }
                
                tableView.endUpdates()
                delegate?.shoplist(updated: dataProvider)
                
            }
        }
    }
    
    
}




