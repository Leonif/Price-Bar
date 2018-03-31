//
//  OutetListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/30/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class OutetListAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var outlets: [Outlet] = [] {
        didSet {
            DispatchQueue.main.async { self.reload()  }
        }
    }
    
    public var onDidSelect: ((Outlet) -> Void)?
    public var onError: ((String) -> Void)?
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // For registering nib files
        tableView.register(UINib(nibName: "OutletCellView", bundle: Bundle.main), forCellReuseIdentifier: "OutletCell")
    }
    
    func reload() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getRowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutletCell", for: indexPath) as! OutletCell
        let object = self.getOutlet(from: indexPath)
        
        return self.configure(cell, for: object)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.getNumberOfSections()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.getOutlet(from: indexPath)
        self.onDidSelect?(object)
    }

    
}


// TODO: Move to adapter protocol
extension OutetListAdapter {
    
    // TODO: Move to adapter protocol
    func getRowsIn(_ section: Int) -> Int {
        return outlets.count
    }
    
    
    // TODO: Move to adapter protocol
    func getOutlet(from indexPath: IndexPath) -> Outlet {
        return outlets[indexPath.row]
    }
    
    // TODO: Move to adapter protocol
    func configure(_ cell: OutletCell, for outlet: Outlet) -> OutletCell {
        
        cell.castShadow()
        cell.layer.cornerRadius = 5.0
        
        if outlet.distance > 600 {
            cell.subviews.forEach { $0.alpha = 0.5 }
        } else {
            cell.subviews.forEach { $0.alpha = 1.0 }
        }
        
        cell.backgroundColor = .clear
        
        
        cell.outletName.text = outlet.name
        let distance = outlet.distance > 1000 ? "\(Int(outlet.distance/1000)) км" : "\(Int(outlet.distance)) м"
        
        
        cell.distanceLabel.text = distance
        cell.outletAddress.text = outlet.address
        
        return cell
    }
    // TODO: Move to adapter protocol
    func getNumberOfSections() -> Int {
        return 1
    }
}
