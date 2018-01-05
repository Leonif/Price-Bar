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
    
}

class ShopListDataSource: NSObject, UITableViewDataSource {
   
    var shopList: ShopListModel!
    var delegate: ShopListDataSourceDelegate?
    
    
    init(shopList: ShopListModel) {
        self.shopList = shopList
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopList.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            if let shp = shopList.getItem(index: indexPath) {
                cell.configureCell(item: shp)
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headeView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {
            
            headeView.categoryLabel.text = shopList.headerString(for: section)
            return headeView
        }
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopList.sectionCount
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopList.headerString(for: section)
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
