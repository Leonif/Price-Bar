//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit


class ShopListController: UIViewController {
    // MARK: IB Outlets
    
    let outletNameButton2: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        b.backgroundColor = .yellow
        b.setTitleColor(.black, for: .normal)
        b.setTitle("", for: .normal)
        return b
        
    }()
    
    @IBOutlet weak var outletAddressLabel: UILabel!
    
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var scanButton: GoodButton!
    @IBOutlet weak var itemListButton: GoodButton!
    @IBOutlet weak var removeShoplistBtn: GoodButton!
    @IBOutlet weak var rightButtonViewArea: UIView!
    @IBOutlet var wholeViewArea: UIView!

    @IBOutlet weak var rightButtonConstrait: NSLayoutConstraint!
    @IBOutlet weak var removeButtonConstrait: NSLayoutConstraint!
    
    // MARK: - Dependecy Injection properties
    var dataProvider: DataProvider!
    var interactor: ShoplistInteractor!
    var syncAnimator: SyncAnimator!
    
    
    var userOutlet: Outlet! { didSet {  updateUI() }  }
    var adapter: ShopListAdapter!
    var buttonsHided: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Assembly Dependency Injection
        dataProvider = DataProvider()
        syncAnimator = SyncAnimator(parent: self)
        interactor = ShoplistInteractor(dataProvider: dataProvider)
        adapter = ShopListAdapter(parent: self, tableView: shopTableView,
                                  dataProvider: dataProvider)
        
        // MARK: - Setup UI
        setupNavigation()
        setupGestures()
        updateRemoveButtonState()
        
        // MARK: - Handle depencies
        dataProvider.onUpdateShoplist = { [weak self] in
            self?.adapter.reload()
            self?.updateRemoveButtonState()
        }
        dataProvider.onSyncProgress = { [weak self] (progress, max, text) in
            self?.syncAnimator.syncHandle(for: progress.double,
                                          and: max.double,
                                          with: text)
        }

        adapter?.onCellDidSelected = { [weak self] item in
            self?.performSegue(withIdentifier: Strings.Segues.showEditItem.name, sender: item)
        }
        synchronizeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200.0)
    }
    
    
    
    
    // MARK: - Setup functions
    func setupNavigation() {
        let width = view.frame.width-16
        outletNameButton2.frame = CGRect(x: 0, y: 0, width: width, height: 34)
        outletNameButton2.addTarget(self, action: #selector(selectOutlet), for: .touchUpInside)
        navigationItem.prompt = "Пожалуйста, выберите магазин"
        self.navigationItem.titleView = outletNameButton2
        navigationController!.navigationBar.shadowImage = UIImage()

    }
    
    
    
    func setupGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        rightSwipe.direction = .right
        wholeViewArea.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        leftSwipe.direction = .left
        wholeViewArea.addGestureRecognizer(leftSwipe)
    }
    
    // MARK: - UI
    func updateUI() {
        DispatchQueue.main.async {
            self.outletAddressLabel.text = self.userOutlet.address
            self.outletNameButton2.setTitle(self.userOutlet.name, for: .normal)
            self.dataProvider.loadShopList(for: self.userOutlet.id)
            self.adapter.reload()
            self.updateRemoveButtonState()
        }
    }
    
    func updateRemoveButtonState() {
        totalLabel.text = "\(Strings.Common.total.localized)\(dataProvider.total.asLocaleCurrency)"
        let enable = !buttonsHided && !dataProvider.shoplist.isEmpty
        removeShoplistBtn.setEnable(enable)
    }
    
    
    // MARK: - Syncing ...
    func synchronizeData() {
        self.buttonEnable(false)
        self.syncAnimator.startProgress()
        interactor?.synchronizeData { [weak self] result in
            self?.syncAnimator.stopProgress(completion: {
                switch result {
                case .success:
                    self?.updateCurentOutlet()
                case let .failure(error):
                    self?.alert(message: "\(error.message): \(error.localizedDescription)")
                }
            })
        }
    }

    private func updateCurentOutlet() {
        var activateControls = false
        self.view.pb_startActivityIndicator(with: Strings.ActivityIndicator.outlet_looking.localized)
        interactor?.updateCurrentOutlet { [weak self] (result) in
            self?.view.pb_stopActivityIndicator()
            switch result {
            case let .success(outlet):
                self?.userOutlet = outlet
                self?.showBaseStatistics()
                activateControls = true
            case let .failure(error):
                let previousSuccess = Strings.Alerts.good_news.localized
                self?.alert(message: "\(previousSuccess)\n\(error.errorDescription)\n\(Strings.Alerts.try_later.localized))")
            }
            self?.buttonEnable(activateControls)
        }
    }
    
    func buttonEnable(_ enable: Bool) {
        DispatchQueue.main.async {
            [self.scanButton, self.itemListButton, self.outletNameButton2]
                .forEach { $0.setEnable(enable) }
        }
    }

    // FIXME: move to separate manager
    func showBaseStatistics() {
        DispatchQueue.main.async {
            let q = self.interactor?.getQuantityOfGood() ?? 0
            let statVC = BaseStatisticsVC(productsCount: q)
            self.present(statVC, animated: true, completion: nil)
        }
    }

    // MARK: - Butons handlers
    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showScan.name, sender: nil)
     }
    
    @objc
    func selectOutlet() {
       performSegue(withIdentifier: Strings.Segues.showOutlets.name, sender: nil)
    }
    @IBAction func itemListPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showItemList.name, sender: nil)
    }
    
    @IBAction func cleanShopList(_ sender: GoodButton) {
        alert(title: Strings.Alerts.wow.localized,
              message: Strings.Alerts.clean_shoplist.localized, okAction: {
            self.dataProvider.clearShoplist()
            self.shopTableView.reloadData()
        }, cancelAction: {})
    }
}

// FIXME: - move to Animator
extension ShopListController {
    @objc
    func hideButtons(gesture: UIGestureRecognizer) {
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
        
        [scanButton, itemListButton].forEach { $0.setEnable(hide) }
        
        let newConst: CGFloat = rightButtonConstrait.constant - shiftOfDirection * 50
        let newRemoveConst: CGFloat = removeButtonConstrait.constant - shiftOfDirection * 50
        
        self.rightButtonConstrait.constant = newConst
        self.removeButtonConstrait.constant = newRemoveConst
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: {  self.view.layoutIfNeeded()  })
    }
}

// MARK: - Scanner handling
extension ShopListController: ScannerDelegate {
    func scanned(barcode: String) {
        print(barcode)
        interactor?.addToShoplist(with: barcode, and: userOutlet.id) { [weak self] result in
            switch result {
            case .success:
                print("Product add to shoplist")
                self?.shopTableView.reloadData()
            case let .failure(error):
                switch error {
                case .productIsNotFound:
                    self?.performSegue(withIdentifier: Strings.Segues.scannedNewProduct.name,
                                      sender: barcode)
                default:
                    self?.alert(message: error.message)
                }
            }
        }
    }
}

extension ShopListController: ItemListVCDelegate {
    func itemChoosen(productId: String) {
        interactor?.addToShoplist(with: productId, and: userOutlet.id) { [weak self] result in
            switch result {
            case .success:
                self?.adapter.reload()
            case let .failure(error):
                self?.alert(message: error.message)
            }
        }
    }
}

extension ShopListController: OutletVCDelegate {
    func choosen(outlet: Outlet) {
        userOutlet = outlet
    }
}

extension ShopListController: ItemCardVCDelegate {
    func add(new productId: String) {
        print(productId)
        interactor?.addToShoplist(with: productId, and: userOutlet.id) { [weak self] result in
            switch result {
            case .success:
                print("Product is added to base and shoplist")
            case let .failure(error):
                self?.alert(message: error.message)
            }
        }
    }
    
    func productUpdated() { // товар был отредактирован (цена/категория/ед измерения)
        interactor?.reloadProducts(outletId: userOutlet.id)
    }
}

// MARK: - transition
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
