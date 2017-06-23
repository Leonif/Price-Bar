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

    var shopList = ShopListModel()
    let locationManager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D?
    var userOutlet: Outlet!
    var selfDefined: Bool = false
    var selfLoaded: Bool = false
    
    @IBOutlet weak var outletNameButton: UIButton!
    @IBOutlet weak var outletAddressLabel: UILabel!
    @IBOutlet weak var sliderView: UISlider!
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        //shopTableView.addGestureRecognizer(longpress)
        _ = shopList.readInitData()
        
        
        
    }
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        startReceivingLocationChanges()
        
        
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shopTableView.reloadData()
    }
    
    

   @IBAction func quantitySliderChanged(_ sender: UISlider) {
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                if let shp = shopList.getItem(index: indexPath) {
                    shp.quantity = step(baseValue: Double(sender.value), step: shp.uom.increment)
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
    
    @IBAction func newItemPressed(_ sender: Any) {
        let um = ShopItemUom()
        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Новая единица", quantity: 1.00, price: 0.00, category: "Неопредленно", uom: um, outletId: userOutlet.id, scanned: false))
        shopTableView.reloadData()
     }
    
    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: AppCons.showScan.rawValue, sender: nil)
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

protocol Exchange {
    func objectExchange(object: Any)
}

//MARK: Handlers based Exchange protocol
extension ShopListController: Exchange {
    
    func objectExchange(object: Any) {
        
        if let item = object as? ShopItem  {//item changed came
            shopList.change(item)
        } else if let outlet = object as? Outlet  {//outlet came
            userOutlet = outlet
            outletNameButton.setTitle(userOutlet.name, for: .normal)
            outletAddressLabel.text = userOutlet.address
            
            shopList.pricesUpdate(by: userOutlet.id)
            
            
            if let shpLst = CoreDataService.data.loadShopList(outletId: userOutlet.id), !selfLoaded {
                shopList = shpLst
                totalLabel.update(value: shopList.total)
                selfLoaded = true
            }
            
            
            
        } else if let code = object as? String {//scann came
            print(code)
            let item: ShopItem!
            if let it = CoreDataService.data.getItem(by: code, and: userOutlet.id) {
                item = it
            } else {
                item = ShopItem(id: code, name: "Неизвестно", quantity: 1.0, price: 0.0, category: "Неизвестно", uom: ShopItemUom(), outletId: userOutlet.id, scanned: true)
            }
            shopList.append(item: item)
            CoreDataService.data.addToShopList(item)
        }
        shopTableView.reloadData()
        totalLabel.update(value: shopList.total)
    }
    
}

//MARK: Outlets
extension ShopListController {
    @IBAction func outletPressed(_ sender: Any) {
        performSegue(withIdentifier: AppCons.showOutlets.rawValue, sender: userCoordinate)
    }
}

//MARK: Drag cells into other category and between each others
extension ShopListController {
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
//        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
//        let state = longPress.state
//        let locationInView = longPress.location(in: shopTableView)
//        let indexPath = shopTableView.indexPathForRow(at: locationInView)
//        
//        struct My {
//            static var cellSnapshot : UIView? = nil
//        }
//        struct Path {
//            static var initialIndexPath : IndexPath? = nil
//        }
//        
//        switch state {
//        case UIGestureRecognizerState.began:
//            if indexPath != nil {
//                Path.initialIndexPath = indexPath
//                let cell = shopTableView.cellForRow(at: indexPath!) as UITableViewCell!
//                My.cellSnapshot = snapshopOfCell(inputView: cell!)
//                var center = cell?.center
//                My.cellSnapshot!.center = center!
//                My.cellSnapshot!.alpha = 0.0
//                shopTableView.addSubview(My.cellSnapshot!)
//                
//                UIView.animate(withDuration: 0.25, animations: { () -> Void in
//                    center?.y = locationInView.y
//                    My.cellSnapshot!.center = center!
//                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
//                    My.cellSnapshot!.alpha = 0.98
//                    cell?.alpha = 0.0
//                    
//                }, completion: { (finished) -> Void in
//                    if finished {
//                        cell?.isHidden = true
//                    }
//                })
//            }
//        case UIGestureRecognizerState.changed:
//            
//            if var center = My.cellSnapshot?.center {
//                center.y = locationInView.y
//                My.cellSnapshot!.center = center
//                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
//                    //change places
//                    if let a = shopList.getItem(index: indexPath!), let b = shopList.getItem(index: Path.initialIndexPath!) {
//                    
//                        if let c = b.copy() as? ShopItem {
//                            
//                            c.category = a.category
//                            shopList.remove(item: b)
//                            shopList.append(item: c)
//                            
//                            //  shopTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
//                            Path.initialIndexPath = indexPath
//                            shopTableView.reloadData()
//                            
//                        }
//                    }
//                }
//            }
//            
//            
//        default:
//            if let pIndex = Path.initialIndexPath, let cell = shopTableView.cellForRow(at:pIndex) {
//                cell.isHidden = false
//                cell.alpha = 0.0
//                UIView.animate(withDuration: 0.25, animations: { () -> Void in
//                    My.cellSnapshot!.center = cell.center
//                    My.cellSnapshot!.transform = CGAffineTransform.identity
//                    My.cellSnapshot!.alpha = 0.0
//                    cell.alpha = 1.0
//                }, completion: { (finished) -> Void in
//                    
//                    if finished {
//                        Path.initialIndexPath = nil
//                        My.cellSnapshot!.removeFromSuperview()
//                        My.cellSnapshot = nil
//                    }
//                })
//            }
//        }
//        
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
        performSegue(withIdentifier: AppCons.showProductCard.rawValue, sender: shopList.getItem(index: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showProductCard.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
            }
        }
        if segue.identifier == AppCons.showOutlets.rawValue, let outletVC = segue.destination as? OutletsVC  {
            outletVC.delegate = self
            if let userCoord = sender as? CLLocationCoordinate2D {
                outletVC.userCoordinate = userCoord
            }
            
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

