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

class ItemListVC: UIViewController {
    let showProductCard = "showProductCard"
    
    var itemList = [ItemListModelView]()
    var filtredItemList = [ItemListModelView]()
    var currentPageOffset = 0
    var router: ItemListRouter!
    var data: ItemListRouterDataStorage!
    
    
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    weak var delegate: ItemListVCDelegate?
    weak var itemCardDelegate: ItemCardVCDelegate?
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar(frame: CGRect.zero)
        s.placeholder = R.string.localizable.item_list_start_to_search_product()
        s.delegate = self
        return s
    }()

    var shouldClose: Bool = false
    weak var repository: Repository!

    var isLoading = false


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.router = ItemListRouter()
        self.data = ItemListRouterDataStorage(repository: repository, vc: self, outletId: outletId)
        
        navigationItem.prompt = R.string.localizable.item_list()
        navigationItem.titleView = searchBar
        
        itemTableView.register(UINib(nibName: "AddCellNib", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        self.view.pb_startActivityIndicator(with: R.string.localizable.common_loading())
    }

    
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToNumPad()
        guard
            let products = repository.getShopItems(with: currentPageOffset, limit: 40, for: outletId),
            let itemList = ProductMapper.transform(from: products, for: outletId)  else {
                alert(message: R.string.localizable.item_list_empty())
                self.view.pb_stopActivityIndicator()
                return
        }

        self.itemList = itemList.sorted { $0.currentPrice > $1.currentPrice  }

        filtredItemList = self.itemList.sorted { $0.currentPrice > $1.currentPrice  }
        itemTableView.reloadData()
        self.view.pb_stopActivityIndicator()
    }

    func updateResults(searchText: String) {
        if  searchText.count >= 3 {
            guard let list = repository.filterItemList(contains: searchText, for: outletId),
                let modelList = ProductMapper.transform(from: list, for: outletId) else {
                    return
            }
            filtredItemList = modelList
        } else {
            filtredItemList = itemList
        }
        itemTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        if shouldClose {
            self.close()
            shouldClose = false
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        self.close()
    }
}

extension ItemListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let newText = (searchBar.text as NSString?)?.replacingCharacters(in: range, with: text) else {
            return true
        }
        self.updateResults(searchText: newText)
        
        return true
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
    @objc
    func numDonePressed() {
        searchBar.resignFirstResponder()
    }
    func addDoneButtonToNumPad() {
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let flex = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                              target: self, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(numDonePressed))

        toolbarDone.items = [flex, barBtnDone] // You can even add cancel button too
        searchBar.inputAccessoryView = toolbarDone
    }
}


extension ItemListVC {
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showProductCard,
            let itemCardVC = segue.destination as? ItemCardVC,
            let searchedItem = sender as? String else {
                return
        }
        itemCardVC.delegate = self
        itemCardVC.outletId = outletId
        itemCardVC.searchedItemName = searchedItem
        itemCardVC.repository = repository
    }
    
}

// FIXME: Move to adapter
extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 0 {
            if !self.isLoading {
                self.isLoading = true
                currentPageOffset += filtredItemList.count
                if let products = repository.getShopItems(with: currentPageOffset,
                                                            limit: 40,
                                                            for: outletId),
                    let modelList = ProductMapper.transform(from: products, for: outletId) {
                    
                    var indexPaths = [IndexPath]()
                    let currentCount: Int = filtredItemList.count
                    
                    for i in 0..<modelList.count {
                        indexPaths.append(IndexPath(row: currentCount + i, section: 0))
                    }
                    
                    if filtredItemList.isEmpty {
                        itemTableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                    
                    // do the insertion
                    filtredItemList.append(contentsOf: modelList)
                    self.itemList.append(contentsOf: modelList)
                    
                    // tell the table view to update (at all of the inserted index paths)
                    self.itemTableView.update {
                        itemTableView.insertRows(at: indexPaths, with: .bottom)
                    }
                }
                self.isLoading = false
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLoading {
            return filtredItemList.count
        }
        return filtredItemList.isEmpty ? 1 : filtredItemList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filtredItemList.isEmpty {
//            self.performSegue(withIdentifier: self.showProductCard, sender: self.searchBar.text)
            self.router.openItemCard(for: self.searchBar.text!, data: self.data)
            
            return
        }

        let item = filtredItemList[indexPath.row]
        self.close()
        self.delegate?.itemChoosen(productId: item.id)

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filtredItemList.isEmpty,
            let cellAdd = itemTableView.dequeueReusableCell(withIdentifier: "CustomCellOne", for: indexPath) as? AddCell {
            return cellAdd
        } else if let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell {
            let item = filtredItemList[indexPath.row]
            cell.configureCell(item)
            return cell
        }
        fatalError()

    }
}
