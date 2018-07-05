//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit



protocol ItemListView: BaseView {
    func onFetchedNewBatch(items: [ItemListViewEntity])
    
}

class ItemListVC: UIViewController, UIGestureRecognizerDelegate, ItemListView {
    
    @IBOutlet weak var tableView: UITableView!
    var outletId: String = ""
   

    var presenter: ItemListPresenter!
    var adapter: ItemListAdapter!
    
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

    
    func onFetchedNewBatch(items: [ItemListViewEntity]) {
        guard !items.isEmpty else { return }
        
        self.adapter.addNewBatch(nextBatch: items)
    }
    
    private func setupAdapter() {
        
        self.tableView.delegate = self.adapter
        self.tableView.dataSource = self.adapter
        
        self.tableView.register(AddCell.self)
        self.tableView.register(ItemListCell.self)
        
        self.adapter.tableView = tableView
        
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
        
        self.adapter.onError = { [weak self] errorString in
            self?.onError(with: errorString)
        }
        
        self.adapter.onGetNextBatch = { (offset, limit) in
            self.presenter.onFetchData(offset: offset, limit: limit, for: self.outletId)
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
    
    @objc func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension ItemListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.onFilterList(basedOn: searchText, with: outletId)
    }
}




