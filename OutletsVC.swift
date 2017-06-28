//
//  OutletsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit
import CoreLocation

class OutletsVC: UIViewController {
    
    var outletListModel = OutletListModel()
    var delegate: Exchange!
    @IBOutlet weak var outletTableView: UITableView!
    var userCoordinate: CLLocationCoordinate2D?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        outletListModel.loadOultets(userCoordinate: userCoordinate!, completed: {
            self.outletTableView.reloadData()
            
        })
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


//MARK: Table
extension OutletsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outletListModel.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.objectExchange(object: outletListModel.getOutlet(index: indexPath))
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = outletTableView.dequeueReusableCell(withIdentifier: "OutletCell", for: indexPath) as? OutletCell {
            
            let outlet = outletListModel.getOutlet(index: indexPath)
                cell.configureCell(outlet: outlet)
                return cell
        }
        
        return UITableViewCell()
    }
}
