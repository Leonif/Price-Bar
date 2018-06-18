//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit


protocol ShoplistView:  class {
    func onIsProductHasPrice(isHasPrice: Bool, barcode: String)
    func onSyncProgress(progress: Double, max: Double, text: String)
    func onUpdateCurrentOutlet()
    func onSyncError(error: String)
    func onCurrentOutletUpdated(outlet: Outlet)
    func onError(error: String)
    func onSavePrice()
    func onProductIsNotFound(productId: String)
    func onAddedItemToShoplist(productId: String)
    func updateUI()
}


class ShopListController: UIViewController, ShoplistView {
    
    // MARK: IB Outlets
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var itemListButton: UIButton!
    @IBOutlet weak var rightButtonViewArea: UIView!
    @IBOutlet var wholeViewArea: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var rightButtonConstrait: NSLayoutConstraint!
    
    var navigationView: NavigationView!
    
    // MARK: - Dependecy Injection properties
//    var repository: Repository!
    var presenter: ShoplistPresenter!

    var adapter: ShopListAdapter!
    
    var syncAnimator: SyncAnimator!
    
    
    private var buttonsHided: Bool = false
    
    private let storeButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        let icon = R.image.storeButton()
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit

        return b
    }()
    
    private let deleteButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        b.setImage(R.image.deleteButton(), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        
        return b
    }()
    
    var userOutlet: Outlet!
//        didSet {
////            self.data.outlet = userOutlet
//            self.updateUI()
//        }
//    }
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.alpha = 1.0
    }
    
    
    // MARK: - Presenter events
    func onIsProductHasPrice(isHasPrice: Bool, barcode: String) {
        if !isHasPrice {
            self.presenter.onOpenUpdatePrice(for: barcode, outletId: self.userOutlet.id)
        }
        self.shopTableView.reloadData()
    }
    
    func onSyncProgress(progress: Double, max: Double, text: String) {
        self.syncAnimator.syncHandle(for: Double(progress),
                                     and: Double(max),
                                     with: text)
    }
    
    func onUpdateCurrentOutlet() {
        self.syncAnimator.stopProgress { [weak self] in
            self?.presenter.updateCurrentOutlet()
        }
    }
    
    func onAddedItemToShoplist(productId: String) {
        self.presenter.isProductHasPrice(for: productId, in: self.userOutlet.id)
    }
    
    
    func onSyncError(error: String) {
        self.syncAnimator.stopProgress { [weak self] in
            self?.presenter.onOpenIssueVC(with: error)
        }
    }
    
    func onCurrentOutletUpdated(outlet: Outlet) {
        self.view.pb_stopActivityIndicator()
        self.userOutlet = outlet
        self.presenter.onReloadShoplist(for: userOutlet.id)
        self.presenter.onOpenStatistics()
        self.buttonEnable(true)
    }
    
    func onSavePrice() {
        self.presenter.reloadProducts(outletId: userOutlet.id)
    }

    
    func onProductIsNotFound(productId: String) {
        self.presenter.onOpenNewItemCard(for: productId)
    }
    
    
    func onError(error: String) {
//        let previousSuccess = R.string.localizable.common_good_news()
//        self.openIssueVC(issue: "\(previousSuccess)\n\(error.errorDescription)\n\(R.string.localizable.common_try_later()))")
        self.presenter.onOpenIssueVC(with: error)
        self.buttonEnable(false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Setup UI
        self.setupNavigation()
        
        PriceBarStyles.grayBorderedRounded.apply(to: self.buttonsView)
        PriceBarStyles.shadowAround.apply(to: self.buttonsView)
        
        self.setupGestures()
        self.updateRemoveButtonState()
        self.setupTotalView()
        
        // MARK: - Handle depencies
//        repository.onUpdateShoplist = { [weak self] in
//            guard let `self` = self else { return }
//            self.shopTableView.reloadData()
//            self.updateRemoveButtonState()
//        }
        self.setupAdapter()
        self.synchronizeData()
    }
    
    
    func setupAdapter() {
        
        self.shopTableView.delegate = self.adapter
        self.shopTableView.dataSource = self.adapter
        
        self.shopTableView.register(ShopItemCell.self)
        
        self.shopTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.shopTableView.rowHeight = UITableViewAutomaticDimension
        
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        
        self.adapter.onCellDidSelected = { [weak self] item in
            guard let `self` = self else { return }
//            self.openItemCard(for: item, data: self.data)
            self.presenter.onOpenItemCard(for: item, with: self.userOutlet.id)
        }
        
        self.adapter.onCompareDidSelected = { [weak self] item in
            guard let `self` = self else { return }
//            self.openUpdatePrice(for: item.productId, currentPrice: item.productPrice, data: self.data)
            self.presenter.onOpenUpdatePrice(for: item.productId, outletId: self.userOutlet.id)
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
        PriceBarStyles.grayBorderedRounded.apply(to: self.totalView)
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
            
            self.shopTableView.reloadData()
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
        self.presenter.startSyncronize()
        self.syncAnimator.startProgress()
    }

    
    
    private func buttonEnable(_ enable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            [self.scanButton, self.itemListButton, self.storeButton].forEach { $0.setEnable(enable) }
        }
    }

    // MARK: - Butons handlers
    @IBAction func scanItemPressed(_ sender: Any) {
        self.presenter.onOpenScanner()
     }
    
    @objc
    func selectOutlet() {
        self.presenter.onOpenOutletList()
    }
    @IBAction func itemListPressed(_ sender: Any) {
        self.presenter.onOpenItemList(for: userOutlet.id)
    }
    
    @IBAction func cleanShopList(_ sender: GoodButton) {
        self.cleanShoplist()
    }
    
    
    @objc
    func cleanShoplist() {
        self.alert(message: R.string.localizable.shoplist_clean(), okAction: { [weak self] in
            guard let `self` = self else { return }
            self.presenter.onCleanShopList()
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
        buttonsHided.toggle()
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
        self.presenter.addToShoplist(with: barcode, and: userOutlet.id)
    }
}

extension ShopListController: ItemListVCDelegate {
    func itemChoosen(productId: String) {
//        if let outlet = userOutlet.id {
        self.presenter.isProductHasPrice(for: productId, in: userOutlet.id)
//        }
        self.presenter.addToShoplist(with: productId, and: userOutlet.id)
    }
}

extension ShopListController: OutletVCDelegate {
    func choosen(outlet: Outlet) {
        userOutlet = outlet
    }
}

extension ShopListController: ItemCardVCDelegate {
    func add(new productId: String) {
        self.presenter.addToShoplist(with: productId, and: userOutlet.id)
    }
    
    func productUpdated() { // товар был отредактирован (цена/категория/ед измерения)
        presenter?.reloadProducts(outletId: userOutlet.id)
    }
}
//extension ShopListController: ItemCardRoute {}

//extension ShopListController: UpdatePriceRoute {
//    func onSavePrice() {
//        guard let outlet = self.data.outlet else {
//            fatalError("No outlet data")
//        }
//        self.presenter.reloadProducts(outletId: outlet.id)
//    }
//}
//
//extension ShopListController: StatisticsRoute {}
//extension ShopListController: ItemListRoute {}
//extension ShopListController: ScannerRoute {}
//extension ShopListController: OutletListRoute {}
//extension ShopListController: IssueRoute {
//    func onTryAgain() {
//        self.synchronizeData()
//    }
//}

