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
    
    let storeButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        let icon = R.image.storeButton()
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit

        return b
    }()
    
    let deleteButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        b.setImage(R.image.deleteButton(), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        
        return b
    }()
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var itemListButton: UIButton!
    @IBOutlet weak var rightButtonViewArea: UIView!
    @IBOutlet var wholeViewArea: UIView!
    @IBOutlet weak var buttonsView: UIView!
    var navigationView: NavigationView!

    @IBOutlet weak var rightButtonConstrait: NSLayoutConstraint!
    
    // MARK: - Dependecy Injection properties
    var repository: Repository!
    var interactor: ShoplistInteractor!
    var router: ShoplistRouter!
    var data: DataStorage!
    
    var syncAnimator: SyncAnimator!
    
    var userOutlet: Outlet! {
        didSet {
            self.data.outlet = userOutlet
            self.updateUI()
        }
    }
    var adapter: ShopListAdapter!
    var buttonsHided: Bool = false
    
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.alpha = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Assembly Dependency Injection
        self.repository = Repository()
        self.syncAnimator = SyncAnimator(parent: self)
        self.interactor = ShoplistInteractor(repository: repository)
        
        
        self.router = ShoplistRouter()
        self.data = DataStorage(repository: self.repository, vc: self, outlet: userOutlet)
        
        self.adapter = ShopListAdapter(parent: self, tableView: shopTableView,
                                  repository: repository)
        
        // MARK: - Setup UI
        self.setupNavigation()
        
        
        PriceBarStyles.grayBorderedRoundedView.apply(to: self.buttonsView)
        PriceBarStyles.shadowAround.apply(to: self.buttonsView)
        
        self.setupGestures()
        self.updateRemoveButtonState()
        self.setupTotalView()
        
        // MARK: - Handle depencies
        repository.onUpdateShoplist = { [weak self] in
            guard let `self` = self else { return }
            self.adapter.reload()
            self.updateRemoveButtonState()
        }
        repository.onSyncProgress = { [weak self] (progress, max, text) in
            guard let `self` = self else { return }
            self.syncAnimator.syncHandle(for: Double(progress),
                                          and: Double(max),
                                          with: text)
        }

        self.setupAdapter()
        self.synchronizeData()
    }
    
    
    func setupAdapter() {
        self.shopTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.shopTableView.rowHeight = UITableViewAutomaticDimension
        
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        
        self.adapter.onCellDidSelected = { [weak self] item in
            self?.performSegue(withIdentifier: Strings.Segues.showEditItem.name, sender: item)
        }
        
        self.adapter.onCompareDidSelected = { [weak self] item in
            guard let `self` = self else { return }

            self.router.openUpdatePrice(for: item.productId, data: self.data)
            self.router.onSavePrice = { [weak self] in
                guard let `self` = self else { return }
                
                guard let outlet = self.data.outlet else {
                    fatalError("No outlet data")
                }
                self.interactor.reloadProducts(outletId: outlet.id)
            }
        }
        
    }
    
    // MARK: - Setup functions
    func setupNavigation() {
        
        self.navigationView = R.nib.navigationView.firstView(owner: self)
        
        self.storeButton.addTarget(self, action: #selector(self.selectOutlet), for: .touchUpInside)
        self.deleteButton.addTarget(self, action: #selector(self.cleanShoplist), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.storeButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.deleteButton)
        
        self.navigationItem.titleView = self.navigationView
        
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    func setupTotalView() {
        PriceBarStyles.grayBorderedRoundedView.apply(to: self.totalView)
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
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.navigationView.outletName.text = self.userOutlet.name
            self.navigationView.outletAddress.text = self.userOutlet.address
            self.repository.loadShopList(for: self.userOutlet.id)
            self.adapter.reload()
            self.updateRemoveButtonState()
        }
    }
    
    func updateRemoveButtonState() {
        self.totalLabel.text = String(format:"%.2f UAH", self.repository.total)
        let enable = !self.repository.shoplist.isEmpty
        self.deleteButton.setEnable(enable)
    }
    
    
    // MARK: - Syncing ...
    func synchronizeData() {
        self.buttonEnable(false)
        self.syncAnimator.startProgress()
        self.interactor.synchronizeData { [weak self] result in
            guard let `self` = self else { return }
            self.syncAnimator.stopProgress(completion: { [weak self] in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    self.updateCurentOutlet()
                case let .failure(error):
                    self.alert(message: "\(error.message): \(error.localizedDescription)")
                }
            })
        }
    }

    private func updateCurentOutlet() {
        var activateControls = false
        self.view.pb_startActivityIndicator(with:R.string.localizable.outlet_looking())
        self.interactor.updateCurrentOutlet { [weak self] (result) in
            guard let `self` = self else { return }
            self.view.pb_stopActivityIndicator()
            switch result {
            case let .success(outlet):
                self.userOutlet = outlet
                self.router.openStatistics(data: self.data)
                activateControls = true
            case let .failure(error):
                let previousSuccess = R.string.localizable.common_good_news()
                self.alert(message: "\(previousSuccess)\n\(error.errorDescription)\n\(R.string.localizable.common_try_later()))")
            }
            self.buttonEnable(activateControls)
        }
    }
    
    func buttonEnable(_ enable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            [self.scanButton, self.itemListButton, self.storeButton].forEach { $0.setEnable(enable) }
        }
    }

    // MARK: - Butons handlers
    @IBAction func scanItemPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showScan.name, sender: nil)
     }
    
    @objc
    func selectOutlet() {
       performSegue(withIdentifier: R.segue.shopListController.showOutlets, sender: nil)
    }
    @IBAction func itemListPressed(_ sender: Any) {
        performSegue(withIdentifier: Strings.Segues.showItemList.name, sender: nil)
    }
    
    @IBAction func cleanShopList(_ sender: GoodButton) {
        self.cleanShoplist()
    }
    
    
    @objc
    func cleanShoplist() {
        self.alert(message: R.string.localizable.shoplist_clean(), okAction: { [weak self] in
            guard let `self` = self else { return }
            self.repository.clearShoplist()
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
            self.shiftButton(hide: buttonsHided)
        case .left:
            self.shiftButton(hide: buttonsHided)
        default:
            print("other swipes")
        }
    }
    
    
    func shiftButton(hide: Bool) {
        let shiftOfDirection: CGFloat = hide ? -1 : 1
        buttonsHided.toggle()// = !buttonsHided
        updateRemoveButtonState()
        [scanButton, itemListButton].forEach { $0.setEnable(hide) }
        let newConst: CGFloat = rightButtonConstrait.constant - shiftOfDirection * 100
        self.rightButtonConstrait.constant = newConst
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: { [weak self] in self?.view.layoutIfNeeded() })
    }
}

// MARK: - Scanner handling
extension ShopListController: ScannerDelegate {
    func scanned(barcode: String) {
        self.interactor.addToShoplist(with: barcode, and: userOutlet.id) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                if !self.interactor.isProductHasPrice(for: barcode, in: self.userOutlet.id) {
                    self.router.openUpdatePrice(for: barcode, data: self.data)
                }
                self.shopTableView.reloadData()
            case let .failure(error):
                switch error {
                case .productIsNotFound:
                    self.performSegue(withIdentifier: R.segue.shopListController.scannedNewProduct.identifier,
                                      sender: barcode)
                    
                default: self.alert(message: error.message)
                }
            }
        }
    }
}

extension ShopListController: ItemListVCDelegate {
    func itemChoosen(productId: String) {
        if let outlet = data.outlet, !self.interactor.isProductHasPrice(for: productId, in: outlet.id) {
            self.router.openUpdatePrice(for: productId, data: data)
        }
        self.interactor.addToShoplist(with: productId, and: userOutlet.id) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.adapter.reload()
            case let .failure(error):
                self.alert(message: error.message)
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
        self.interactor.addToShoplist(with: productId, and: userOutlet.id) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success: break
            case let .failure(error):  self.alert(message: error.message)
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
        self.router.prepare(for: segue, sender: sender, data: self.data)
    }
}



