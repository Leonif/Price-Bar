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
    
    var outletService = OutletService()
    
    var delegate: Exchange!
    @IBOutlet weak var outletTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityContainerView: UIView!
    var userCoordinate: CLLocationCoordinate2D?
    var outlets = [Outlet]()
    
    @IBOutlet weak var warningLocationView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userCoordinate = userCoordinate    {
            self.view.pb_startActivityIndicator(with: "Загрузка торговых точек")
            outletService.loadOultets(userCoordinate: userCoordinate, completed: { result in
                self.view.pb_stopActivityIndicator()
                switch result {
                case let .success(outlets):
                    self.outlets = outlets
                    self.outletTableView.reloadData()
                case let .failure(error):
                    self.alert(title: "error", message: error.localizedDescription)
                }
            })
        } else {
            warningLocationView.isHidden = false
        }
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
        return outlets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let outlet = outlets[indexPath.row]
        
        delegate.objectExchange(object: outlet)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = outletTableView.dequeueReusableCell(withIdentifier: "OutletCell", for: indexPath) as? OutletCell {
            
            let outlet = outlets[indexPath.row]
            cell.configureCell(outlet: outlet)
            return cell
        }
        
        return UITableViewCell()
    }
}
