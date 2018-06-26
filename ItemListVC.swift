//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit



protocol ItemListView: BaseView {
    func onFetchedData(items: [ItemListModelView])
    func onFetchedNewBatch(items: [ItemListModelView])
    
}

class ItemListVC: UIViewController, UIGestureRecognizerDelegate, ItemListView {
    
    @IBOutlet weak var tableView: UITableView!
    var outletId: String = ""
   
    var router: ItemListRouter!
    var presenter: ItemListPresenter!

//    var data: ItemListRouterDataStorage!
    var adapter: ItemListAdapter!
    
//    var shouldClose: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar(frame: CGRect.zero)
        s.placeholder = R.string.localizable.item_list_start_to_search_product()
        s.delegate = self
        return s
    }()

    let backButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        let icon = R.image.backButton()
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAdapter()
        self.setupNavigation()
    }

    
    func onFetchedNewBatch(items: [ItemListModelView]) {
        self.adapter.addNewBatch(nextBatch: items)
    }
    
    func onFetchedData(items: [ItemListModelView]) {
        self.adapter.updateDatasorce(sortedItems: items)
    }
    
    private func setupAdapter() {
        
        self.tableView.delegate = adapter
        self.tableView.dataSource = adapter
        
        self.tableView.register(AddCell.self)
        self.tableView.register(ItemListCell.self)
        
        
        self.adapter.onStartLoading = { [weak self] in
            self?.view.pb_startActivityIndicator(with: R.string.localizable.common_loading())
        }
        
        self.adapter.onAddNewItem = { [weak self] in
            guard let `self` = self else { return }
            guard let suggestedName = self.searchBar.text else { return }
            
            self.presenter.onAddNewItem(suggestedName: suggestedName)
            self.close()
            
        }
        self.adapter.onItemChoosen = { [weak self] itemId in
            self?.close()
            self?.presenter.onItemChoosen(productId: itemId)
        }
        
        self.adapter.onStopLoading = { [weak self] in
            self?.view.pb_stopActivityIndicator()
        }
        
        self.adapter.onError = { [weak self] errorString in
            self?.alert(message: errorString)
        }
        
        self.adapter.onGetData = { (offset, limit) in
            self.presenter.onFetchData(offset: offset, limit: limit, for: self.outletId)
        }
        
        self.adapter.onGetNextBatch = { (offset, limit) in
            self.presenter.onFetchNextBatch(offset: offset, limit: limit, for: self.outletId)
        }
        
        
        self.adapter.loadItems()
        
    }
    
    private func setupNavigation() {
        PriceBarStyles.grayBorderedRounded.apply(to: searchBar.textField)
        self.navigationItem.titleView = searchBar
        
        self.backButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchBar.addToolBar()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        if shouldClose {
//            self.close()
//            shouldClose.toggle()
//        } else {
//            self.tableView.reloadData()
//        }
//    }
    
    @objc func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ItemListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.onFilterList(basedOn: searchText, with: outletId)
    }
}

//
//extension ItemListVC: ItemCardVCDelegate {
//    func productUpdated() {
//        itemCardDelegate?.productUpdated()
//    }
//    func add(new productId: String) {
//        shouldClose = true
//        itemCardDelegate?.add(new: productId)
//    }
//}



extension ItemListVC {
    
}
