//
//  ItemListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/29/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


class ItemListAdapter: NSObject, UITableViewDataSource {
    
    var tableView: UITableView!

    var dataSource: [ItemListViewEntity] = []
    var filtredItemList: [ItemListViewEntity] = []
    var currentPageOffset: Int = 0
    
    var isLoading = false
    
    var onAddNewItem: (() -> Void)? = nil
    var onItemChoosen: ((String) -> Void)? = nil

    var onGetNextBatch: ((Int, Int) -> Void)? = nil

    var onError: ((String) -> Void)? = nil
    var limit = 40
    
    
    
    func loadItems() {
        self.onGetNextBatch?(currentPageOffset, limit)
    }
    
    func updateDatasorce(sortedItems: [ItemListViewEntity]) {
        self.dataSource = sortedItems
        self.filtredItemList = sortedItems
        self.reload()
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return filtredItemList.count
        }
        return filtredItemList.isEmpty ? 1 : filtredItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filtredItemList.isEmpty {
            let cellAdd: AddCell = tableView.dequeueReusableCell(for: indexPath)
            return cellAdd
        } else {
            let cell: ItemListCell = self.tableView.dequeueReusableCell(for: indexPath)
            let item = filtredItemList[indexPath.row]
            cell.configureCell(item)
            return cell
        }
    }
    
    
}

extension ItemListAdapter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filtredItemList.isEmpty {
            self.onAddNewItem?()
            return
        }
        let item = filtredItemList[indexPath.row]
        self.onItemChoosen?(item.id)
    }
}


extension ItemListAdapter {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.dataSource.count - 1 {
            self.isLoading = true
            self.currentPageOffset += self.limit
            self.onGetNextBatch?(self.currentPageOffset, self.limit)
        }
    }
    
    func addNewBatch(nextBatch: [ItemListViewEntity]) {
        self.isLoading.toggle()
        var indexPaths = [IndexPath]()
        let currentCount: Int = filtredItemList.count
        
        for i in 0..<nextBatch.count {
            indexPaths.append(IndexPath(row: currentCount + i, section: 0))
        }
        
        if filtredItemList.isEmpty {
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
        
        // do the insertion
        filtredItemList.append(contentsOf: nextBatch)
        self.dataSource.append(contentsOf: nextBatch)
        self.reload()
        
    }
}

