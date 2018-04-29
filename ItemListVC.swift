//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ItemListVCDelegate: class {
    func itemChoosen(productId: String)
}

class ItemListVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var outletId: String = ""
   
    var router: ItemListRouter!
    var data: ItemListRouterDataStorage!
    var adapter: ItemListAdapter!
    
    var shouldClose: Bool = false
    
    weak var repository: Repository!
    weak var delegate: ItemListVCDelegate?
    weak var itemCardDelegate: ItemCardVCDelegate?
    
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
        
        self.router = ItemListRouter()
        self.data = ItemListRouterDataStorage(repository: repository, vc: self, outletId: outletId)
        
        self.setupAdapter()
        self.setupNavigation()
        
    }

    
    private func setupAdapter() {
        self.adapter = ItemListAdapter(tableView: self.tableView,
                                       repository: self.repository,
                                       outletId: outletId)
        
//        self.adapter.onStartLoading = { [weak self] in
//            self?.view.pb_startActivityIndicator(with: R.string.localizable.common_loading())
//        }
        
        self.adapter.onAddNewItem = { [weak self] in
            guard let `self` = self else { return }
            self.router.openItemCard(for: self.searchBar.text!, data: self.data)
        }
        self.adapter.onItemChoosen = { [weak self] itemId in
            self?.close()
            self?.delegate?.itemChoosen(productId: itemId)
        }
        
//        self.adapter.onStopLoading = { [weak self] in
//            self?.view.pb_stopActivityIndicator()
//        }
        
        self.adapter.onError = { [weak self] errorString in
            self?.alert(message: errorString)
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

    override func viewWillAppear(_ animated: Bool) {
        if shouldClose {
            self.close()
            shouldClose.toggle()
        } else {
            self.tableView.reloadData()
        }
    }
}

extension ItemListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.adapter.updateResults(searchText: searchText)
    }
}


extension ItemListVC: ItemCardVCDelegate {
    func productUpdated() {
        itemCardDelegate?.productUpdated()
    }
    func add(new productId: String) {
        shouldClose = true
        itemCardDelegate?.add(new: productId)
    }
}



extension ItemListVC {
    @objc func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
