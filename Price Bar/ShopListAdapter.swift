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
        tableView.register(R.nib.shopItemCell(), forCellReuseIdentifier: "ItemCell")
        
    }
    
    func reload() {
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repository.rowsIn(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ShopItemCell
        let shp = repository.getItem(index: indexPath)!

        self.configure(cell, shp)
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.repository.getItem(index: indexPath)!
        self.onCellDidSelected?(item)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView
        headerView?.view.layer.cornerRadius = 8.0
        headerView?.view.layer.borderColor = Color.darkGray.cgColor
        headerView?.view.layer.borderWidth = 1.0
        headerView?.categoryLabel.text = repository.headerString(for: section)

        return headerView
    }
    
    
    func configure(_ cell: ShopItemCell, _ item: DPShoplistItemModel) {
        
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.cellView.layer.cornerRadius = 8.0
        cell.cellView.castShadow()
        
        [cell.quantityButton, cell.priceView].forEach {
            $0?.layer.cornerRadius = 8.0
            $0?.layer.borderWidth = 1.0
            $0?.layer.borderColor = Color.darkGray.cgColor
        }
        
        
        cell.nameItem.text = item.productName
        cell.priceItem.text = "\(item.productPrice.asLocaleCurrency)"
        cell.uomLabel.text = item.productUom
        
        self.updateWeigh(for: cell, item.quantity, item.productPrice)
    }
    
    
    func updateWeigh(for cell: ShopItemCell, _ weight: Double, _ price: Double) {
        
        let total = weight * price
        
        let btnTitle = String(format:"%@ %.2f", R.string.localizable.shop_list_quantity(), weight)
        
        cell.quantityButton.setTitle(btnTitle, for: .normal)
        cell.totalItem.text = total.asLocaleCurrency
    }
    
    
}



// MARK: - Cell handlers
extension ShopListAdapter {
    func handleWeightDemanded(cell: ShopItemCell) {
        print("Picker opened")
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


