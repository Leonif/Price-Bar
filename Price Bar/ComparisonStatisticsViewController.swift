//
//  ComparisonStatisticsViewController.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/28/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class ComparisonStatisticsViewController: UIViewController {
    
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    public var dataSource: [StatisticModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib(nibName: "PriceStatisticCell", bundle: Bundle.main), forCellReuseIdentifier: "ItemCell")
        
        
        
        self.productTitle.text = self.dataSource.first?.productName
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


extension ComparisonStatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! PriceStatisticCell
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
