//
//  ItemListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/29/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


// FIXME: Move to adapter
extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 0 {
            if !self.isLoading {
                self.isLoading = true
                currentPageOffset += filtredItemList.count
                if let products = repository.getShopItems(with: currentPageOffset,
                                                          limit: 40,
                                                          for: outletId),
                    let modelList = ProductMapper.transform(from: products, for: outletId) {
                    
                    var indexPaths = [IndexPath]()
                    let currentCount: Int = filtredItemList.count
                    
                    
                    
                    
                    for i in 0..<modelList.count {
                        indexPaths.append(IndexPath(row: currentCount + i, section: 0))
                    }
                    
                    if filtredItemList.isEmpty {
                        self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                    
                    // do the insertion
                    filtredItemList.append(contentsOf: modelList)
                    self.itemList.append(contentsOf: modelList)
                    
                    // tell the table view to update (at all of the inserted index paths)
                    self.tableView.update {
                        self.tableView.insertRows(at: indexPaths, with: .bottom)
                    }
                }
                self.isLoading = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return filtredItemList.count
        }
        return filtredItemList.isEmpty ? 1 : filtredItemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filtredItemList.isEmpty {
            self.router.openItemCard(for: self.searchBar.text!, data: self.data)
            return
        }
        
        let item = filtredItemList[indexPath.row]
        self.close()
        self.delegate?.itemChoosen(productId: item.id)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filtredItemList.isEmpty {
            let cellAdd: AddCell = self.tableView.dequeueReusableCell(for: indexPath)
            return cellAdd
        } else {
            let cell: ItemListCell = self.tableView.dequeueReusableCell(for: indexPath)
            let item = filtredItemList[indexPath.row]
            cell.configureCell(item)
            return cell
        }
    }
}
