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
            let products = repository.getShopItems(with: currentPageOffset, limit: 40, for: outletId),
            let itemList = ProductMapper.transform(from: products, for: outletId)  else {
                self.onError?(R.string.localizable.item_list_empty())
                self.onStopLoading?()
                return
        }
        
        self.dataSource = itemList.sorted { $0.currentPrice > $1.currentPrice  }
        
        filtredItemList = self.dataSource.sorted { $0.currentPrice > $1.currentPrice  }
        self.tableView.reloadData()
        
        self.onStopLoading?()
    }
    
    
    func updateResults(searchText: String) {
        if  searchText.count >= 3 {
            guard let list = repository.filterItemList(contains: searchText, for: outletId),
                let modelList = ProductMapper.transform(from: list, for: outletId) else {
                    return
            }
            filtredItemList = modelList
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 0 {
            if !self.isLoading {
                self.isLoading = true
                
                self.currentPageOffset += filtredItemList.count
                self.addNewBatch(offset: self.currentPageOffset, limit: 40)
                
                self.isLoading = false
            }
        }
    }
    
    
    
    func addNewBatch(offset: Int, limit: Int) {
        if let products = repository.getShopItems(with: offset,
                                                  limit: limit,
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
            self.dataSource.append(contentsOf: modelList)
            
            // tell the table view to update (at all of the inserted index paths)
            self.tableView.update {
                self.tableView.insertRows(at: indexPaths, with: .bottom)
            }
        }
    }
}

