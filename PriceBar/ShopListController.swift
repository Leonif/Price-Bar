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
    var dataProvider: DataProvider!
    var userOutlet: Outlet! {
        didSet {
            outletAddressLabel.text = userOutlet.address
            outletNameButton.setTitle(userOutlet.name, for: .normal)
        }
    }
    var dataSource: ShopListDataSource?
    
    
    @IBOutlet weak var outletNameButton: UIButton!
    @IBOutlet weak var outletAddressLabel: UILabel!
    
    
    
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider = DataProvider()
        dataSource = ShopListDataSource(delegate: self, cellDelegate: self, shopListService: dataProvider)
        shopTableView.dataSource = dataSource
        
        // sync from cloud
        self.view.pb_startActivityIndicator(with: "Синхронизация")
        dataProvider.syncCloud { result in
            self.view.pb_stopActivityIndicator()
            switch result {
            case let .failure(error):
                self.alert(title: "Ops", message: error.localizedDescription)
            case .success:
                break
            }
        }
        
        let outletService = OutletService()
        outletService.nearestOutlet { result in
            print(result)
            var activateControls = false
            switch result {
            case let .success(outlet):
                print(outlet)
                self.userOutlet = outlet
                activateControls = true
            case let .failure(error):
                self.alert(title: "Ops", message: error.errorDescription)
            }
            self.buttonEnable(activateControls)
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
        performSegue(withIdentifier: showOutlets, sender: nil)
    }
    @IBAction func cleanShopList(_ sender: GoodButton) {
        
        shopTableView.beginUpdates()
        dataProvider.removeAllItems()
        shopTableView.endUpdates()
        
        
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


//MARK: Cell handlers
extension ShopListController: ShopItemCellDelegate {
    func weightDemanded(cell: ShopItemCell, currentValue: Double) {
        print("Picker opened")
        guard
            let indexPath = self.shopTableView.indexPath(for: cell),
            let item = dataProvider.getItem(index: indexPath) else {
                fatalError("Not possible to find out type of item")
        }
        let type: QuantityType = item.itemUom.isPerPiece ? .quantity : .weight
        let model = QuantityModel(for: indexPath, with: type, and: currentValue)
        let pickerVC = QuantityPickerPopup(delegate: self, model: model)
        self.present(pickerVC, animated: true, completion: nil)
        
    }
    func checkPressed(for item: ShopItem) {
        _ = dataProvider.change(item)
    }
}

// MARK: Quantity changing of item handler
extension ShopListController: QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath) {
        guard let item = self.dataProvider.getItem(index: indexPath) else {
            return
        }
        item.quantity = weight
        _ = self.dataProvider.change(item)
        self.shopTableView.reloadRows(at: [indexPath], with: .none)
        totalLabel.update(value: dataProvider.total)
    }
}

// MARK: datasource handler
extension ShopListController: ShopListDataSourceDelegate {
    func shoplist(updated shopListService: DataProvider) {
        self.dataProvider = shopListService
        totalLabel.update(value: shopListService.total)
    }
}


//MARK: Table
extension ShopListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showEditItem, sender: dataProvider.getItem(index: indexPath))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {
            
            headerView.categoryLabel.text = dataProvider.headerString(for: section)
            return headerView
        }
        return UIView()
    }
    
}

//MARK: transition
extension ShopListController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEditItem,
            let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
                itemVC.categories = dataProvider.categories
                itemVC.uoms = dataProvider.uoms
            }
        }
        
        if segue.identifier == showOutlets,
            let outletVC = segue.destination as? OutletsVC  {
            outletVC.delegate = self
        }
        if segue.identifier == showItemList,
            let itemListVC = segue.destination as? ItemListVC, userOutlet != nil  {
            itemListVC.outletId = userOutlet.id
            itemListVC.delegate = self
            itemListVC.dataProvider = dataProvider
            
        }
        if segue.identifier == showScan,
            let scanVC = segue.destination as? ScannerController  {
            scanVC.delegate = self
        }
    }
}

