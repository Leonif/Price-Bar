//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ShoplistView: BaseView {
    func onCurrentOutletUpdated(outlet: OutletViewItem)
    func onIssue(error: String)
    func onUpdatedTotal(_ total: Double)
    func onUpdatedShoplist(_ dataSource: [ShoplistDataSource])
    func startIsCompleted()
}



class ShopListController: UIViewController, ShoplistView {

    // MARK: IB Outlets
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var itemListButton: UIButton!
    @IBOutlet weak var rightButtonViewArea: UIView!
    @IBOutlet weak var wholeViewArea: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var rightButtonConstrait: NSLayoutConstraint!
    @IBOutlet weak var leftTotalConstrait: NSLayoutConstraint!
    var animator: SwipeAnimator!
    
    var navigationView: NavigationView!

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
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.alpha = 1.0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.viewDidLoadTrigger()
        
        // MARK: - Setup UI
        self.setupNavigation()
        grayBorderedRoundedWithShadow(self.buttonsView)
        self.setupAnimator()
        self.setupTotalView()
        self.setupAdapter()
        self.adapterBinding()
    }
    
    // MARK: - Presenter events
    func onUpdatedTotal(_ total: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.totalLabel.text = "\(R.string.localizable.common_total()) \(String(format: "%.2f", total))"
        }
    }
    func onUpdatedShoplist(_ dataSource: [ShoplistDataSource]) {
        self.adapter.dataSourceManager.update(dataSource: dataSource)
        DispatchQueue.main.async { [weak self] in
            self?.shopTableView.reloadData()
        }
        self.deleteButton.setEnable(!dataSource.isEmpty)
    }
    
    func onCurrentOutletUpdated(outlet: OutletViewItem) {
        self.view.pb_stopActivityIndicator()
        DispatchQueue.main.async { [weak self] in
            self?.navigationView.outletName.text = outlet.name
            self?.navigationView.outletAddress.text = outlet.address
        }
        self.buttonEnable(true)
    }

    func startIsCompleted() {
        self.presenter.onOpenStatistics()
    }
    
    func onIssue(error: String) {
        self.presenter.openIssueVC(with: error)
        self.buttonEnable(false)
    }
    
    func setupAnimator() {
        animator = SwipeAnimator(swipeViewArea: wholeViewArea)
        animator.appendAnimated(constraints: [leftTotalConstrait, rightButtonConstrait])
        animator.onAnimated = { hide in
            [self.scanButton, self.itemListButton].forEach { $0.setEnable(hide) }
        }
    }
    
    func setupAdapter() {
        self.shopTableView.delegate = self.adapter
        self.shopTableView.dataSource = self.adapter
        
        self.shopTableView.register(ShopItemCell.self)
        self.shopTableView.register(NoteCell.self)
        self.shopTableView.register(HeaderView.self)
        
        self.shopTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.shopTableView.rowHeight = UITableViewAutomaticDimension
        
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        self.shopTableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        self.adapter.tableView = self.shopTableView
    }
  
    func adapterBinding() {
      self.adapter.eventHandler = { [weak self] (event) in
        guard let `self` = self else { return }
        switch event {
        case let .onCellDidSelected(item):
          self.presenter.onOpenItemCard(for: item)
        case let .onCompareDidSelected(item):
          self.presenter.onOpenUpdatePrice(for: item.productId)
        case let.onRemoveItem(itemId):
          self.presenter.onRemoveItem(productId: itemId)
        case let .onQuantityChange(productId):
          self.presenter.onQuantityChanged(productId: productId)
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
        navigationController?.navigationBar.barTintColor = Color.feijoaGreen
        navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    func setupTotalView() {
        PriceBarStyles.grayBorderedRounded.apply(to: self.totalView)
    }
    
    // MARK: - Syncing ...
    private func buttonEnable(_ enable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let buttons = [self.scanButton, self.itemListButton, self.storeButton]
            buttons.forEach { $0!.setEnable(enable) }
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
        self.presenter.onOpenItemList()
    }
    
    @IBAction func cleanShopList(_ sender: GoodButton) {
        self.cleanShoplist()
    }
    
    func close() {  }

    @objc
    func cleanShoplist() {
        self.alert(message: R.string.localizable.shoplist_clean(),
                   okAction: { [weak self] in
                    guard let `self` = self else { return }
                    self.presenter.onCleanShopList()
            }, cancelAction: {})
    }
}
