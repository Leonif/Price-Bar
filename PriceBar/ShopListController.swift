//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit
import CoreLocation

class ShopListController: UIViewController {
    
    fileprivate let showScan = "showScan"
    fileprivate let showItemList = "showItemList"
    fileprivate let showOutlets = "showOutlets"
    fileprivate let showEditItem = "showEditItem"

    @IBOutlet weak var scanButton: GoodButton!
    @IBOutlet weak var itemListButton: GoodButton!
    var shopList: ShopListModel!
    let locationManager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D?
    var userOutlet: Outlet!
    var selfDefined: Bool = false
    var selfLoaded: Bool = false
    var dataSource: ShopListDataSource?
    
    @IBOutlet weak var outletNameButton: UIButton!
    @IBOutlet weak var outletAddressLabel: UILabel!
    
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopList = ShopListModel()
        
        dataSource = ShopListDataSource(shopModel: shopList)
        dataSource?.delegate = self
        
        shopTableView.dataSource = dataSource
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startReceivingLocationChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shopTableView.reloadData()
    }
    
    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: showScan, sender: nil)
     }
    @IBAction func itemListPressed(_ sender: Any) {
        performSegue(withIdentifier: showItemList, sender: nil)
    }
}


//MARK: Cell handlers
extension ShopListController: ShopListDataSourceDelegate {
    func shoplist(updated shopModel: ShopListModel) {
        self.shopList = shopModel
        totalLabel.update(value: shopList.total)
    }
    
    func checkPressed(for item: ShopItem) {
        _ = shopList.change(item)
    }
    func selectedWeight(for item: ShopItem, weight: Double) {
        
        self.shopTableView.beginUpdates()
        let shp = item
        shp.quantity = weight
        _ = shopList.change(shp)
        totalLabel.update(value: shopList.total)
        self.shopTableView.endUpdates()
    }
    
    
    
}


//MARK: User location
extension ShopListController: CLLocationManagerDelegate {
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            locationManager.requestWhenInUseAuthorization()
            //return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoordinate = locations.last?.coordinate
        
        if let userCoord = userCoordinate, !selfDefined {
            let outletService = OutletService()
            outletService.getNearestOutlet(coordinate: userCoord, completion: { result in
                
                var activateControls = false
                switch result {
                case let .success(outlet):
                    self.handle(for: outlet)
                    activateControls = true
                case let .failure(error):
                    activateControls = false
                    self.alert(title: "Ops", message: error.errorDescription)
                }
                self.selfDefined = activateControls
                self.buttonEnable(activateControls)
            })
        }
    }
    
    
    func buttonEnable(_ enable: Bool) {
        
        let alpha: CGFloat = enable ? 1 : 0.5
        
        self.scanButton.alpha = alpha
        self.scanButton.isUserInteractionEnabled = enable
        self.itemListButton.alpha = alpha
        self.itemListButton.isUserInteractionEnabled = enable
        self.outletNameButton.alpha = alpha
        self.outletNameButton.isUserInteractionEnabled = enable
        
    }
    
}


//MARK: Outlets
extension ShopListController {
    @IBAction func outletPressed(_ sender: Any) {
        performSegue(withIdentifier: showOutlets, sender: userCoordinate)
    }
}





//MARK: Table
extension ShopListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showEditItem, sender: shopList.getItem(index: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEditItem, let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
                itemVC.categories = shopList.categories
                itemVC.uoms = shopList.uoms
            }
        }
        
        if segue.identifier == showOutlets, let outletVC = segue.destination as? OutletsVC  {
            outletVC.delegate = self
            if let userCoord = sender as? CLLocationCoordinate2D {
                outletVC.userCoordinate = userCoord
            } else {
                outletVC.userCoordinate = nil
            }
            
        }
        if segue.identifier == showItemList,
            let itemListVC = segue.destination as? ItemListVC, userOutlet != nil  {
            
            itemListVC.outletId = userOutlet.id
            
            itemListVC.delegate = self
            
        }
        if segue.identifier == showScan, let scanVC = segue.destination as? ScannerController  {
            
                scanVC.delegate = self
            
        }
        
    }
    

}

