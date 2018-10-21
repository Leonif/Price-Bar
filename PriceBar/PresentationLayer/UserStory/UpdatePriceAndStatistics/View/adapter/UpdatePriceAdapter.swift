//
//  UpdatePriceAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit



class UpdatePriceAdapter: NSObject,  UITableViewDelegate, UITableViewDataSource {
    
    private var dataSource: [StatisticModel]!
    private var tableView: UITableView!
    
    init(tableView: UITableView, dataSource: [StatisticModel]) {
        super.init()
        
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.dataSource = dataSource
        
        // For registering nib files
        self.tableView.register(PriceStatisticCell.self)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PriceStatisticCell = tableView.dequeueReusableCell(for: indexPath)
        
        let outlet = dataSource[indexPath.row].outlet
        let price = dataSource[indexPath.row].price
        let dateString = dataSource[indexPath.row].date.getString(format: "dd-MM-yy")
        
        cell.outletName.text = outlet.name
        cell.outletAddress.text = outlet.address
        cell.priceInfo.text = "\(price)"
        cell.date.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
}
