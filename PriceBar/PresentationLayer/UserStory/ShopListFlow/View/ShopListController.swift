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

    var navigationView: NavigationView!

    var presenter: ShopListPresenter!
    var adapter: ShopListAdapter!

    private var buttonsHided: Bool = false

    private let storeButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        let icon = R.image.storeButton()
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.setImage(R.image.deleteButton(), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        return button
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
        self.setupGestures()
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

    func setupAdapter() {

        self.shopTableView.delegate = self.adapter
        self.shopTableView.dataSource = self.adapter

        self.shopTableView.register(ShopItemCell.self)
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

    func setupGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        rightSwipe.direction = .right
        wholeViewArea.addGestureRecognizer(rightSwipe)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideButtons))
        leftSwipe.direction = .left
        wholeViewArea.addGestureRecognizer(leftSwipe)
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

    @IBAction func cleanShopList(_ sender: UIButton) {
        self.cleanShoplist()
    }

    func close() {  }

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
