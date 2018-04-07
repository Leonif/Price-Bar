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
        tableView.register(R.nib.outletCellView(), forCellReuseIdentifier: "OutletCell")
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



extension OutetListAdapter {
    func getRowsIn(_ section: Int) -> Int {
        return outlets.count
    }

    func getOutlet(from indexPath: IndexPath) -> Outlet {
        return outlets[indexPath.row]
    }
    
    func configure(_ cell: OutletCell, for outlet: Outlet) -> OutletCell {
        
        cell.castShadow()
        
        cell.layer.cornerRadius = 5.0
        
        if outlet.distance > 600 {
            cell.distanceView.backgroundColor = UIColor.lightGray
        } else {
            cell.distanceView.backgroundColor = Color.neonCarrot
        }
        
        cell.backgroundColor = .clear
        
        
        cell.outletName.text = outlet.name
        
        
        
        let km = R.string.localizable.outlet_list_km("\(Int(outlet.distance/1000))")
        let m = R.string.localizable.outlet_list_m("\(Int(outlet.distance))")
        
        let distance = outlet.distance > 1000 ? km : m
        
        
        cell.distanceLabel.text = distance
        cell.outletAddress.text = outlet.address
        
        return cell
    }

    func getNumberOfSections() -> Int {
        return 1
    }
}
