//
//  ShopListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/5/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

enum ShopListAdapterEvent {
  case onCellDidSelected(ShoplistViewItem)
  case onCompareDidSelected(ShoplistViewItem)
  case onRemoveItem(String)
  case onQuantityChange(String)
}

class ShopListAdapter: NSObject, UITableViewDataSource {
    var tableView: UITableView!

    var eventHandler: EventHandler<ShopListAdapterEvent>?

    var dataSourceManager: ShoplistDatasourceManager!

    private var onWeightDemand: ((ShopItemCell) -> Void)?

    func remove(indexPath: IndexPath) {
        guard let item: ShoplistViewItem = dataSourceManager.getItem(for: indexPath) else {
            return
        }
        self.eventHandler?(.onRemoveItem(item.productId))
        self.dataSourceManager.removeElement(with: indexPath)
        self.tableView.deleteRows(at: [indexPath], with: .fade)

        if !self.dataSourceManager.isExists(indexPath.section) {
            let indexSet = IndexSet(integer: indexPath.section)
            self.tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceManager.getElementsCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopItemCell = tableView.dequeueReusableCell(for: indexPath)
        guard let shp: ShoplistViewItem = self.dataSourceManager.getItem(for: indexPath) else {
            fatalError("item is not found")
        }

        cell.configure(shp)

        let elementsInSection = dataSourceManager.getElementsCount(for: indexPath.section)

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
        } else if isLastCell {
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
            guard let item: ShoplistViewItem = self.dataSourceManager.getItem(for: indexPath) else {
                debugPrint("item for \(indexPath) is not found")
                return
            }
            self.eventHandler?(.onQuantityChange(item.productId))
        }
        cell.onCompareDemand = { [weak self] cell in
            guard let `self` = self else { return }
            guard let item: ShoplistViewItem = self.dataSourceManager.getItem(for: indexPath) else {
                debugPrint("item for \(indexPath) is not found")
                return
            }
            self.eventHandler?(.onCompareDidSelected(item))
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceManager.numberOfSections
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.update { self.remove(indexPath: indexPath)  }
        }
    }
}

// MARK: - Delegate
extension ShopListAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item: ShoplistViewItem = self.dataSourceManager.getItem(for: indexPath) else {
            debugPrint("item for \(indexPath) is not found")
            return
        }
        self.eventHandler?(.onCellDidSelected(item))
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: HeaderView = tableView.dequeueReusableHeaderFooterView()

        let title = self.dataSourceManager.getHeaderTitle(for: section)
        headerView.configure(with: title)

        return headerView
    }
}
