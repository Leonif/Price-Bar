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
    var locationService: LocationService?
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
        locationService = LocationService(input: self)
        dataSource = ShopListDataSource(delegate: self, cellDelegate: self, shopModel: shopList)
        shopTableView.dataSource = dataSource
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let locationService = locationService else {
            fatalError("Location service is not available")
        }
        
        let result = locationService.startReceivingLocationChanges()
        
        switch result {
        case let .failure(error):
            alert(title: "OOps", message: error.errorDescription)
        default:
            print("Location service works")
        }
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
    
    @IBAction func outletPressed(_ sender: Any) {
        performSegue(withIdentifier: showOutlets, sender: userCoordinate)
    }
}


//MARK: Cell handlers
extension ShopListController: ShopItemCellDelegate {
    func weightDemanded(cell: ShopItemCell, currentValue: Double) {
        print("Picker opened")
        guard
            let indexPath = self.shopTableView.indexPath(for: cell),
            let item = shopList.getItem(index: indexPath) else {
                fatalError("Not possible to find out type of item")
        }
        
        let type: QuantityType = item.itemUom.isPerPiece ? .quantity : .weight
        let model = QuantityModel(for: indexPath, type: type, currentValue: currentValue)
        let pickerVC = QuantityPickerPopup(delegate: self, model: model)
        //pickerVC.delegate = self
        //pickerVC.indexPath = indexPath
        self.present(pickerVC, animated: true, completion: nil)
        
    }
    func checkPressed(for item: ShopItem) {
        _ = shopList.change(item)
    }
}

// MARK: Quantity changing of item handler
extension ShopListController: QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath) {
        guard let item = self.shopList.getItem(index: indexPath) else {
            return
        }
        item.quantity = weight
        _ = self.shopList.change(item)
        self.shopTableView.reloadRows(at: [indexPath], with: .none)
        totalLabel.update(value: shopList.total)
    }
}

// MARK: datasource handler
extension ShopListController: ShopListDataSourceDelegate {
    func shoplist(updated shopModel: ShopListModel) {
        self.shopList = shopModel
        totalLabel.update(value: shopList.total)
    }
}


//MARK: Location service handler
extension ShopListController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoordinate = locations.last?.coordinate
        
        if let userCoord = userCoordinate, !selfDefined {
            let outletService = OutletService()
            outletService.getOutlet(near: userCoord, completion: { result in
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

//MARK: Table
extension ShopListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showEditItem, sender: shopList.getItem(index: indexPath))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headeView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {
            
            headeView.categoryLabel.text = shopList.headerString(for: section)
            return headeView
        }
        return UIView()
    }
    
}

//MARK: transition
extension ShopListController {
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

