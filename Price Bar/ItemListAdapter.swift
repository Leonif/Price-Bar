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

    var outletId: String!
    var repository: Repository!
    
    var dataSource: [ItemListModelView] = []
    var filtredItemList: [ItemListModelView] = []
    var currentPageOffset: Int = 0
    
    var isLoading = false
    
    var onAddNewItem: (() -> Void)? = nil
    var onItemChoosen: ((String) -> Void)? = nil
    var onStartLoading: (() -> Void)? = nil
    var onStopLoading: (() -> Void)? = nil
    var onError: ((String) -> Void)? = nil
    var limit = 40
    
    init(tableView: UITableView,
         repository: Repository, outletId: String) {
        super.init()

        self.tableView = tableView
        self.outletId = outletId
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.repository = repository
        
        self.tableView.register(AddCell.self)
        self.tableView.register(ItemListCell.self)
        
    }
    
    func loadItems() {
        self.onStartLoading?()
        guard
            let products = repository.getShopItems(with: currentPageOffset, limit: self.limit, for: outletId) else {
                self.onError?(R.string.localizable.item_list_empty())
                self.onStopLoading?()
                return
        }
        
        self.dataSource = products
            .map { ProductMapper.mapper(from: $0, for: outletId) }
            .sorted { $0.currentPrice > $1.currentPrice  }
        
        filtredItemList = self.dataSource.sorted { $0.currentPrice > $1.currentPrice  }
        self.tableView.reloadData()
        
        self.onStopLoading?()
    }
    
    
    func updateResults(searchText: String) {
        if  searchText.count >= 3 {
            guard let list = repository.filterItemList(contains: searchText, for: outletId) else {
                return
            }
            filtredItemList = list.map { ProductMapper.mapper(from: $0, for: outletId) }
        } else {
            filtredItemList = self.dataSource
        }
        self.tableView.reloadData()
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
        
        print("cur idx: \(indexPath.row), data: \(dataSource.count) ff: \(filtredItemList.count)")
        if indexPath.row == self.dataSource.count - 1 {
            self.isLoading = true
            self.currentPageOffset += self.limit
            self.addNewBatch(offset: self.currentPageOffset, limit: self.limit)
            self.isLoading.toggle()
        }
    }
    
    func addNewBatch(offset: Int, limit: Int) {
        if let products = repository.getShopItems(with: offset,
                                                  limit: limit,
                                                  for: outletId) {
            let modelList = products.map { ProductMapper.mapper(from: $0, for: outletId) }
            
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
            self.dataSource.append(contentsOf: modelList)
            
            // tell the table view to update (at all of the inserted index paths)
//            self.tableView.update {
//                self.tableView.insertRows(at: indexPaths, with: .bottom)
//            }
            
            self.reload()
        }
    }
}
