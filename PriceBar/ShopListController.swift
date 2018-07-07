//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ShoplistView: BaseView {
    func onIsProductHasPrice(isHasPrice: Bool, barcode: String)
    func onCurrentOutletUpdated(outlet: Outlet)
    func onError(error: String)
    func onSavePrice()
    func onProductIsNotFound(productId: String)
    func onAddedItemToShoplist(productId: String)
    func onUpdatedTotal(_ total: Double)
    func onUpdatedShoplist(_ dataSource: [ShoplistItem])
    
    func startIsCompleted()
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
    var presenter: ShoplistPresenter!
    var adapter: ShopListAdapter!
    
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
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.alpha = 1.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Setup UI
        self.setupNavigation()
        
        PriceBarStyles.grayBorderedRounded.apply(to: self.buttonsView)
        PriceBarStyles.shadowAround.apply(to: self.buttonsView)
        
        self.setupGestures()
        self.setupTotalView()
        self.setupAdapter()
        self.presenter.updateCurrentOutlet()
    }
    
    // MARK: - Presenter events
    func onIsProductHasPrice(isHasPrice: Bool, barcode: String) {
        if !isHasPrice {
            self.presenter.onOpenUpdatePrice(for: barcode, outletId: self.userOutlet.id)
        }
    }
    
    func onAddedItemToShoplist(productId: String) {
        self.presenter.isProductHasPrice(for: productId, in: self.userOutlet.id)
        self.presenter.addToShoplist(with: productId, and: userOutlet.id)
    }
    
    func onUpdatedTotal(_ total: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.totalLabel.text = "\(R.string.localizable.common_total()) \(total)"
        }
    }
    
    
    func onUpdatedShoplist(_ dataSource: [ShoplistItem]) {
        self.adapter.dataSource = dataSource
        DispatchQueue.main.async { [weak self] in
            self?.shopTableView.reloadData()
        }
        self.deleteButton.setEnable(!dataSource.isEmpty)
    }
    
    func onCurrentOutletUpdated(outlet: Outlet) {
        self.view.pb_stopActivityIndicator()
        self.presenter.onReloadShoplist(for: outlet.id)
        
        self.userOutlet = outlet
        DispatchQueue.main.async { [weak self] in
            self?.navigationView.outletName.text = self?.userOutlet.name
            self?.navigationView.outletAddress.text = self?.userOutlet.address
        }
        self.buttonEnable(true)
    }
    
    func onSavePrice() {
        self.presenter.onReloadShoplist(for: userOutlet.id)
    }

    func startIsCompleted() {
        self.presenter.onOpenStatistics()
    }
    
    func onProductIsNotFound(productId: String) {
        self.presenter.onOpenNewItemCard(for: productId)
    }
    
    
    func onError(error: String) {
        self.presenter.onOpenIssueVC(with: error)
        self.buttonEnable(false)
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
            self.presenter.onOpenItemCard(for: item, with: self.userOutlet.id)
        }
        
        self.adapter.onCompareDidSelected = { [weak self] item in
            guard let `self` = self else { return }
            self.presenter.onOpenUpdatePrice(for: item.productId, outletId: self.userOutlet.id)
        }
        self.adapter.onRemoveItem = { [weak self] itemId in
            guard let `self` = self else { return }
            self.presenter.onRemoveItem(productId: itemId)
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
        }
    }
    
    // MARK: - Syncing ...
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
    
    func close() {
        
    }
    
    
    @objc
    func cleanShoplist() {
        self.alert(message: R.string.localizable.shoplist_clean(), okAction: { [weak self] in
            guard let `self` = self else { return }
            self.presenter.onCleanShopList()
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




extension ShopListController: ItemCardVCDelegate {
    func add(new productId: String) {
        self.presenter.addToShoplist(with: productId, and: userOutlet.id)
    }
    func productUpdated() { // товар был отредактирован (цена/категория/ед измерения)
        self.presenter?.onReloadShoplist(for: userOutlet.id)
    }
}
