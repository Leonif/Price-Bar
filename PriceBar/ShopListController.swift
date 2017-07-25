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

    var shopList: ShopListModel!
    let locationManager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D?
    var userOutlet: Outlet!
    var selfDefined: Bool = false
    var selfLoaded: Bool = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var outletNameButton: UIButton!
    @IBOutlet weak var outletAddressLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        shopList = ShopListModel(activityIndicator)
        
        
        
        
    }
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        startReceivingLocationChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shopTableView.reloadData()
    }
    
    
    
    
    
    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: AppCons.showScan.rawValue, sender: nil)
     }
    @IBAction func itemListPressed(_ sender: Any) {
        performSegue(withIdentifier: AppCons.showItemList.rawValue, sender: nil)
    }
    
}


//MARK: Cell handlers
extension ShopListController {
    @IBAction func checkMarkPressed(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell), let item = shopList.getItem(index: indexPath)  {
                
                item.checked = !item.checked
                shopList.change(item)
                cell.configureCell(item: item)
                
            }
        }
    }
    
    
    @IBAction func quantitySliderChanged(_ sender: UISlider) {
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                if let shp = shopList.getItem(index: indexPath) {
                    shp.quantity = step(baseValue: Double(sender.value), step: shp.uom.increment)
                    shopList.change(shp)
                    shopTableView.reloadData()
                    
                }
            }
        }
        totalLabel.update(value: shopList.total)
    }
    
    
    func step(baseValue: Double, step: Double) -> Double {
        let result = baseValue/step * step
        return step.truncatingRemainder(dividingBy: 1.0) == 0.0 ? round(result) : result
    }
    
    
    
}





//MARK: User location
extension ShopListController:CLLocationManagerDelegate {
    
    
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
            let outM = OutletListModel()
            outM.delegate = self
            outM.getNearestOutlet(coordinate: userCoord)
           
            
            selfDefined = true
        }
        
    }
}


//MARK: Outlets
extension ShopListController {
    @IBAction func outletPressed(_ sender: Any) {
        performSegue(withIdentifier: AppCons.showOutlets.rawValue, sender: userCoordinate)
    }
}





//MARK: Table
extension ShopListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headeView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {
            
            headeView.categoryLabel.text = shopList.headerString(for: section)
            return headeView
        }
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopList.sectionCount
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopList.headerString(for: section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = shopList.getItem(index: indexPath) {
                shopTableView.beginUpdates()
                CoreDataService.data.removeFromShopList(item)
                let sectionStatus = shopList.remove(item: item)
                
                shopTableView.deleteRows(at: [indexPath], with: .fade)
                if sectionStatus == .sectionEmpty  {
                    let indexSet = IndexSet(integer: indexPath.section)
                    shopTableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
                }
                shopTableView.endUpdates()
                totalLabel.update(value: shopList.total)
                
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopList.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: AppCons.showEditItem.rawValue, sender: shopList.getItem(index: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showEditItem.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
                itemVC.categories = shopList.categories
                itemVC.uoms = shopList.uoms
            }
        }
        
        if segue.identifier == AppCons.showOutlets.rawValue, let outletVC = segue.destination as? OutletsVC  {
            outletVC.delegate = self
            if let userCoord = sender as? CLLocationCoordinate2D {
                outletVC.userCoordinate = userCoord
            } else {
                outletVC.userCoordinate = nil
            }
            
        }
        if segue.identifier == AppCons.showItemList.rawValue,
            let itemListVC = segue.destination as? ItemListVC, userOutlet != nil  {
            
            itemListVC.outletId = userOutlet.id
            
            itemListVC.delegate = self
            
        }
        if segue.identifier == AppCons.showScan.rawValue, let scanVC = segue.destination as? ScannerController  {
            
                scanVC.delegate = self
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = shopTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            if let shp = shopList.getItem(index: indexPath) {
                cell.configureCell(item: shp)
                return cell
            }
            
        }
        
        
        
        return UITableViewCell()
    }
}

