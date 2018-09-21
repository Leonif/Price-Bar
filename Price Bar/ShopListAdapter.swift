//
//  ShopListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/5/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class ShopListAdapter: NSObject, UITableViewDataSource {
    var tableView: UITableView!
    
    var onCellDidSelected: ((ShoplistViewItem) -> Void)?
    var onCompareDidSelected: ((ShoplistViewItem) -> Void)?
    var onRemoveItem: ((String) -> Void)?
    var onQuantityChange: ((String) -> Void)?
    
    var dataSource: [ShoplistDataSource] = []
    
    private var onWeightDemand: ((ShopItemCell) -> Void)?
    
    func getItem<T>(index: IndexPath) -> T {
        return dataSource[index.section].getItem(for: index.row)
    }
    
    func remove(indexPath: IndexPath) {
        let item: ShoplistViewItem = dataSource[indexPath.section].getItem(for: indexPath.row)
        dataSource[indexPath.section].remove(index: indexPath.row)
        self.remove(indexPath.section)
        self.onRemoveItem?(item.productId)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        if dataSource[indexPath.section].getElementCount() == 0 {
            let indexSet = IndexSet(integer: indexPath.section)
            tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func remove(_ section: Int) {
        if dataSource[section].getElementCount() == 0 {
            dataSource.remove(at: section)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].getElementCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemCell = tableView.dequeueReusableCell(for: indexPath)
        let shp:ShoplistViewItem = self.getItem(index: indexPath)

        cell.configure(shp)
        
        
        let elementsInSection = self.dataSource[indexPath.section].getElementCount()
        
        let isFirstAndLastCell = indexPath.row == 0 && indexPath.row ==
            elementsInSection - 1
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row ==  elementsInSection - 1
        
        let wide: CGFloat = 16
        let thin: CGFloat = 8
        
        if  isFirstAndLastCell {
            cell.topConstraint.constant = wide
            cell.bottomConstraint.constant = wide
        } else if isFirstCell {
            cell.bottomView.isHidden = true
            cell.topConstraint.constant = wide
            cell.bottomConstraint.constant = thin
        } else if isLastCell  {
            cell.topView.isHidden = true
            cell.topConstraint.constant = thin
            cell.bottomConstraint.constant = wide
        } else {
            cell.topView.isHidden = true
            cell.bottomView.isHidden = true
            cell.topConstraint.constant = thin
            cell.bottomConstraint.constant = thin
        }
        
        cell.onWeightDemand = { [weak self] cell in
            guard let `self` = self else { return }
            let item: ShoplistViewItem = self.getItem(index: indexPath)
            self.onQuantityChange?(item.productId)
        }
        cell.onCompareDemand = { [weak self] cell in
            guard let `self` = self else { return }
            let item: ShoplistViewItem = self.getItem(index: indexPath)
            self.onCompareDidSelected?(item)
        }
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.update { self.remove(indexPath: indexPath)  }
        }
    }
}


// MARK: -  Delegate
extension ShopListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: ShoplistViewItem = self.getItem(index: indexPath)
        self.onCellDidSelected?(item)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)!.first as! HeaderView
        
        PriceBarStyles.grayBorderedRounded.apply(to: headerView.view)
        headerView.categoryLabel.text = self.dataSource[section].getHeaderTitle()

        return headerView
    }
}


