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
    var repository: Repository!
    var tableView: UITableView!
    
    var vc: UIViewController!
    
    var onCellDidSelected: ((DPShoplistItemModel) -> Void)?
    var onCompareDidSelected: ((DPShoplistItemModel) -> Void)?
    private var onWeightDemand: ((ShopItemCell) -> Void)?

    init(parent: UIViewController,  tableView: UITableView, repository: Repository) {
        super.init()
        
        self.vc = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.repository = repository
        
        // For registering nib files
        tableView.register(R.nib.shopItemCell(), forCellReuseIdentifier: R.reuseIdentifier.itemCell.identifier)
        
    }
    
    func reload() {
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.rowsIn(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.itemCell.identifier, for: indexPath) as! ShopItemCell
        let shp = self.repository.getItem(index: indexPath)!

        self.configure(cell, shp)
        
        
        if indexPath.row == 0 && indexPath.row == self.repository.rowsIn(indexPath.section) - 1 {
            cell.topConstraint.constant = 16
            cell.bottomConstraint.constant = 16
        } else if indexPath.row == 0 {
            cell.topConstraint.constant = 16
            cell.bottomConstraint.constant = 8
        } else if indexPath.row == self.repository.rowsIn(indexPath.section) - 1  {
            cell.topConstraint.constant = 8
            cell.bottomConstraint.constant = 16
        } else {
            cell.topConstraint.constant = 8
            cell.bottomConstraint.constant = 8
        }
        
        
        
        cell.onWeightDemand = { [weak self] cell in
            self?.handleWeightDemanded(cell: cell)
        }
        cell.onCompareDemand = { [weak self] cell in
            guard let `self` = self else { return }
            let item = self.repository.getItem(index: indexPath)!
            self.onCompareDidSelected?(item)
        }
        
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return repository.sectionCount
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = repository.getItem(index: indexPath) {
                tableView.update {
                    let itemCountWasInSection = repository.rowsIn(indexPath.section)
                    repository.remove(item: item)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    if itemCountWasInSection == 1 {
                        let indexSet = IndexSet(integer: indexPath.section)
                        tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                    }
                }
            }
        }
    }
}


// MARK: -  Delegate
extension ShopListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.repository.getItem(index: indexPath)!
        self.onCellDidSelected?(item)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)!.first as! HeaderView
        
        PriceBarStyles.borderedRoundedView.apply(to: headerView.view)
        headerView.categoryLabel.text = repository.headerString(for: section)

        return headerView
    }
    
    
    func configure(_ cell: ShopItemCell, _ item: DPShoplistItemModel) {
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.cellView.layer.cornerRadius = 8.0
        PriceBarStyles.shadowAround.apply(to: cell.cellView)
        
        [cell.quantityButton, cell.priceView].forEach {
            PriceBarStyles.borderedRoundedView.apply(to: $0)
        }
        cell.priceView.backgroundColor = item.productPrice == 0.0 ? Color.petiteOrchid : Color.jaggedIce
        cell.nameItem.text = item.productName
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



// MARK: - Cell handlers
extension ShopListAdapter {
    func handleWeightDemanded(cell: ShopItemCell) {
        guard
            let indexPath = self.tableView.indexPath(for: cell),
            let item = repository.getItem(index: indexPath) else {
                fatalError("Not possible to find out type of item")
        }
        
        let currentValue = repository.getQuantity(for: item.productId)!
        let model = QuantityModel(parameters: item.parameters,
                                  indexPath: indexPath,
                                  currentValue: currentValue)
        let pickerVC = QuantityPickerPopup(delegate: self, model: model)
        self.vc.present(pickerVC, animated: true, completion: nil)
    }
}

// MARK: - Quantity changing of item handler
extension ShopListAdapter: QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath) {
        guard let item = self.repository.getItem(index: indexPath) else {
            return
        }
        repository.changeShoplistItem(weight, for: item.productId)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}


