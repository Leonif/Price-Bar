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
    
    
    let showProductCard = "showProductCard"
    
    var itemList = [ItemListModelView]()
    var filtredItemList = [ItemListModelView]()
    var currentPageOffset = 0
    var isLoading = false
    var outletId: String = ""
   
    var router: ItemListRouter!
    var data: ItemListRouterDataStorage!
    
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
        
        self.setupNavigation()
        
        self.tableView.register(UINib(nibName: "AddCellNib", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        self.tableView.register(ItemListCell.self)
        self.view.pb_startActivityIndicator(with: R.string.localizable.common_loading())
    }

    
    private func setupNavigation() {
        PriceBarStyles.grayBorderedRounded.apply(to: searchBar.textField)
        self.navigationItem.titleView = searchBar
        
        self.backButton.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
        self.tableView.reloadData()
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
        self.tableView.reloadData()
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
    @objc func close() {
        self.navigationController?.popViewController(animated: true)
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
                        self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                    
                    // do the insertion
                    filtredItemList.append(contentsOf: modelList)
                    self.itemList.append(contentsOf: modelList)
                    
                    // tell the table view to update (at all of the inserted index paths)
                    self.tableView.update {
                        self.tableView.insertRows(at: indexPaths, with: .bottom)
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
            self.router.openItemCard(for: self.searchBar.text!, data: self.data)
            return
        }

        let item = filtredItemList[indexPath.row]
        self.close()
        self.delegate?.itemChoosen(productId: item.id)

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filtredItemList.isEmpty,
            let cellAdd = self.tableView.dequeueReusableCell(withIdentifier: "CustomCellOne", for: indexPath) as? AddCell {
            return cellAdd
        } else {
            let cell: ItemListCell = self.tableView.dequeueReusableCell(for: indexPath)
            let item = filtredItemList[indexPath.row]
            cell.configureCell(item)
            return cell
        }
    }
}
