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

    @IBOutlet weak var scanButton: GoodButton!
    @IBOutlet weak var itemListButton: GoodButton!
    @IBOutlet weak var removeShoplistBtn: GoodButton!
    @IBOutlet weak var rightButtonViewArea: UIView!
    @IBOutlet var wholeViewArea: UIView!

    @IBOutlet weak var rightButtonConstrait: NSLayoutConstraint!
    @IBOutlet weak var removeButtonConstrait: NSLayoutConstraint!
    
    var dataProvider: DataProvider = DataProvider()

    var userOutlet: Outlet! {
        didSet {
            updateUI()
        }
    }
    var dataSource: ShopListDataSource?

    @IBOutlet weak var outletNameButton: UIButton!
    @IBOutlet weak var outletAddressLabel: UILabel!

    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    var buttonsHided: Bool = false
    
    func updateUI() {
        DispatchQueue.main.async {
            self.outletAddressLabel.text = self.userOutlet.address
            self.outletNameButton.setTitle(self.userOutlet.name, for: .normal)
            self.dataProvider.loadShopList(for: self.userOutlet.id)
            self.shopTableView.reloadData()
            self.updateRemoveButtonState()
        }
    }
    
    func updateRemoveButtonState() {
        totalLabel.text = "\(Strings.Common.total.localized)\(dataProvider.total.asLocaleCurrency)"
        let enable = !buttonsHided && !dataProvider.shoplist.isEmpty
        removeShoplistBtn.setEnable(enable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        rightSwipe.direction = .right
        wholeViewArea.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        leftSwipe.direction = .left
        wholeViewArea.addGestureRecognizer(leftSwipe)
        
        updateRemoveButtonState()
        
        dataProvider.updateClousure = updateRemoveButtonState
        dataSource = ShopListDataSource(cellDelegate: self,
                                        dataProvider: dataProvider)
        shopTableView.dataSource = dataSource
        synchronizeData()
    }
    
    @objc func hideButtons(gesture: UIGestureRecognizer) {
        guard userOutlet != nil else {
            return
        }
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
            return
        }
        switch swipeGesture.direction {
        case .right:
            shiftButton(hide: buttonsHided)
        case .left:
            shiftButton(hide: buttonsHided)
        default:
            print("other swipes")
        }
    }
    
    func shiftButton(hide: Bool) {
        let shiftOfDirection: CGFloat = hide ? -1 : 1
        buttonsHided = !buttonsHided
        updateRemoveButtonState()
        [scanButton, itemListButton].forEach {
            $0.setEnable(hide)
        }
        let newConst: CGFloat = rightButtonConstrait.constant - shiftOfDirection * 50
        let newRemoveConst: CGFloat = removeButtonConstrait.constant - shiftOfDirection * 50
        
        self.rightButtonConstrait.constant = newConst
        self.removeButtonConstrait.constant = newRemoveConst

        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: {
                        self.view.layoutIfNeeded()
        })
    }
    
    func synchronizeData() {
        self.buttonEnable(false)
        self.view.pb_startActivityIndicator(with: Strings.ActivityIndicator.sync_process.localized)
        dataProvider.syncCloud { [weak self] result in
            self?.view.pb_stopActivityIndicator()
            switch result {
            case let .failure(error):
                self?.alert(message: "\(error.message): \(error.localizedDescription)")
            case .success:
                self?.updateCurentOutlet()
            }
        }
    }

    private func updateCurentOutlet() {
        self.view.pb_startActivityIndicator(with: Strings.ActivityIndicator.outlet_looking.localized)
        let outletService = OutletService()
        outletService.nearestOutlet { [weak self] result in
            self?.view.pb_stopActivityIndicator()
            print(result)
            var activateControls = false
            switch result {
            case let .success(outlet):
                self?.userOutlet = OutletFactory.mapper(from: outlet)
                activateControls = true
            case let .failure(error):
                let prevousSuccess = Strings.Alerts.good_news.localized
                self?.alert(message: "\(prevousSuccess)\n\(error.errorDescription)\n\(Strings.Alerts.try_later.localized))")
            }
            self?.buttonEnable(activateControls)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shopTableView.reloadData()
    }

    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showScan.name, sender: nil)
     }
    @IBAction func itemListPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showItemList.name, sender: nil)
    }

    @IBAction func outletPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showOutlets.name, sender: nil)
    }
    @IBAction func cleanShopList(_ sender: GoodButton) {
        alert(title: "Ого", message: "Чистим шоп лист?🧐", okAction: {
            self.dataProvider.clearShoplist()
            self.shopTableView.reloadData()
        }, cancelAction: {})

    }
    func buttonEnable(_ enable: Bool) {
        DispatchQueue.main.async {
            [
                self.scanButton,
                self.itemListButton,
                self.outletNameButton
                ].forEach {
                    $0?.setEnable(enable)
            }
           
        }
    }
}




// MARK: Cell handlers
extension ShopListController: ShopItemCellDelegate {
    func weightDemanded(cell: ShopItemCell) {
        print("Picker opened")
        guard
            let indexPath = self.shopTableView.indexPath(for: cell),
            let item = dataProvider.getItem(index: indexPath) else {
                fatalError("Not possible to find out type of item")
        }
        
        let currentValue = dataProvider.getQuantity(for: item.productId)!
        let model = QuantityModel(parameters: item.parameters,
                                   indexPath: indexPath,
                                   currentValue: currentValue)
        let pickerVC = QuantityPickerPopup(delegate: self, model: model)
        self.present(pickerVC, animated: true, completion: nil)
    }
    func checkPressed(for item: DPShoplistItemModel) {
        _ = dataProvider.change(item)
    }
}

// MARK: Quantity changing of item handler
extension ShopListController: QuantityPickerPopupDelegate {
    func choosen(weight: Double, for indexPath: IndexPath) {
        guard let item = self.dataProvider.getItem(index: indexPath) else {
            return
        }
        dataProvider.changeShoplistItem(weight, for: item.productId)
        self.shopTableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: Table
extension ShopListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Strings.Segues.showEditItem.name, sender: dataProvider.getItem(index: indexPath))
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {

            headerView.categoryLabel.text = dataProvider.headerString(for: section)
            return headerView
        }
        return UIView()
    }
}

// MARK: transition
extension ShopListController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Strings.Segues.showEditItem.name,
            let itemCardVC = segue.destination as? ItemCardVC {
            if let item = sender as? DPShoplistItemModel {
                itemCardVC.item = item
                itemCardVC.delegate = self
                itemCardVC.dataProvider = dataProvider
                itemCardVC.outletId = userOutlet.id
            }
        }
        if segue.identifier == Strings.Segues.scannedNewProduct.name,
            let itemCardVC = segue.destination as? ItemCardVC {
            if let barcode = sender as? String {
                itemCardVC.barcode = barcode
                itemCardVC.delegate = self
                itemCardVC.dataProvider = dataProvider
                itemCardVC.outletId = userOutlet.id
            }
        }

        if segue.identifier == Strings.Segues.showOutlets.name,
            let outletVC = segue.destination as? OutletsVC {
            outletVC.delegate = self
        }
        if segue.identifier == Strings.Segues.showItemList.name,
            let itemListVC = segue.destination as? ItemListVC, userOutlet != nil {
            itemListVC.outletId = userOutlet.id
            itemListVC.delegate = self
            itemListVC.itemCardDelegate = self
            itemListVC.dataProvider = dataProvider

        }
        if segue.identifier == Strings.Segues.showScan.name,
            let scanVC = segue.destination as? ScannerController {
            scanVC.delegate = self
        }
    }
}
