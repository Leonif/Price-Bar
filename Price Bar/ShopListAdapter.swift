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
    var vc: UIViewController!
    
    var onCellDidSelected: ((ShoplistItem) -> Void)?
    var onCompareDidSelected: ((ShoplistItem) -> Void)?
    var onRemoveItem: ((String) -> Void)?
    var onQuantityChange: ((String) -> Void)?
    
    var sectionNames: [String] = []
    var dataSource: [ShoplistItem] = [] {
        didSet {
            self.sectionNames = []
            dataSource.forEach { item in
                if !sectionNames.contains(item.productCategory) {
                    sectionNames.append(item.productCategory)
                }
            }
        }
    }
    
    private var onWeightDemand: ((ShopItemCell) -> Void)?
    init(parent: UIViewController) {
        super.init()
        self.vc = parent
    }
    
    func getRowsInSection(_ section: Int) -> Int {
        let count = self.dataSource.reduce(0) { (result, item) in
            result + (item.productCategory == sectionNames[section] ? 1 : 0)
        }
        return count
    }
    
    func getItem(index: IndexPath) -> ShoplistItem {
        let sec = index.section
        let indexInSec = index.row
        let productListInsection = self.dataSource.filter { $0.productCategory == sectionNames[sec] }
        return productListInsection[indexInSec]
    }
    
    func headerString(for section: Int) -> String {
        guard !sectionNames.isEmpty else {
            return "No section"
        }
        
        return sectionNames[section]
    }
    
    
    // FIXME: move to presenter
    func remove(item: ShoplistItem) {
        guard let index = self.dataSource.index(of: item) else {
            fatalError("item doesnt exist")
        }
        self.dataSource.remove(at: index)
        self.removeSection(with: item.productCategory)
        self.onRemoveItem?(item.productId)
    }
    
    // FIXME: move to presenter
    func removeSection(with name: String) {
        guard let index = sectionNames.index(of: name) else {
            return
        }
        
        for item in self.dataSource {
            if item.productCategory == name {
                debugPrint("section \(name) can't be removed cause contains some items")
                return
            }
        }
        self.sectionNames.remove(at: index)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemCell = tableView.dequeueReusableCell(for: indexPath)
        let shp = self.getItem(index: indexPath)

        self.configure(cell, shp)
        
        
        let isFirstAndLastCell = indexPath.row == 0 && indexPath.row == self.getRowsInSection(indexPath.section) - 1
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == self.getRowsInSection(indexPath.section) - 1
        
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
            let item = self.getItem(index: indexPath)
            self.onQuantityChange?(item.productId)
        }
        cell.onCompareDemand = { [weak self] cell in
            guard let `self` = self else { return }
            let item = self.getItem(index: indexPath)
            self.onCompareDidSelected?(item)
        }
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.getItem(index: indexPath)
            tableView.update {
                let itemCountWasInSection = self.getRowsInSection(indexPath.section)
                self.remove(item: item)
                tableView.deleteRows(at: [indexPath], with: .fade)
                if itemCountWasInSection == 1 {
                    let indexSet = IndexSet(integer: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                }
            }
        }
    }
}


// MARK: -  Delegate
extension ShopListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.getItem(index: indexPath)
        self.onCellDidSelected?(item)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)!.first as! HeaderView
        
        PriceBarStyles.grayBorderedRounded.apply(to: headerView.view)
        headerView.categoryLabel.text = self.headerString(for: section)

        return headerView
    }
    
    
    func configure(_ cell: ShopItemCell, _ item: ShoplistItem) {
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.cellView.layer.cornerRadius = 8.0
        PriceBarStyles.shadowAround.apply(to: cell.cellView)
        
        PriceBarStyles.grayBorderedRounded.apply(to: cell.quantityButton, cell.priceView)
        
        cell.priceView.backgroundColor = item.productPrice == 0.0 ? Color.petiteOrchid : Color.jaggedIce
        cell.nameItem.text = item.fullName
        cell.priceItem.text = String(format: "%.2f", item.productPrice)
        cell.uomLabel.text = item.productUom
        
        self.updateWeight(for: cell, item.quantity, item.productPrice)
    }
    
    
    func updateWeight(for cell: ShopItemCell, _ weight: Double, _ price: Double) {
        
        let total = weight * price
        
        let btnTitle = String(format:"%@ %.2f", R.string.localizable.shop_list_quantity(), weight)
        
        cell.quantityButton.setTitle(btnTitle, for: .normal)
        cell.totalItem.text = String(format: "UAH\n%.2f", total)
    }
}


