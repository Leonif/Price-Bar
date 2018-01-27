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
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    weak var delegate: ItemListVCDelegate?
    weak var itemCardDelegate: ItemCardVCDelegate?
    var emptyList: Bool = false
    
    
    var shouldClose: Bool = false
    var dataProvider: DataProvider!
    
    var isLoading = false
    @IBOutlet weak var itemSearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.register(UINib(nibName: "AddCellNib", bundle: nil), forCellReuseIdentifier: "CustomCellOne")
        
        
        self.view.pb_startActivityIndicator(with: "Загрузка...")
    }
    
    var currentPageOffset = 0
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToNumPad()
        guard
            let products = dataProvider.getShopItems(with: currentPageOffset, for: outletId),
            let itemList = ProductMapper.transform(from: products, for: outletId)
            else {
                alert(title: "Ops", message: "Нет товаров в базе")
                self.view.pb_stopActivityIndicator()
                return
        }
        
        self.itemList = itemList.sorted { (item1, item2) in
            item1.currentPrice > item2.currentPrice
        }
        
        filtredItemList = self.itemList.sorted { (item1, item2) in
            item1.currentPrice > item2.currentPrice
        }
        itemTableView.reloadData()

        self.view.pb_stopActivityIndicator()
    }
    
    @IBAction func itemSearchFieldChanged(_ sender: UITextField) {
        if  let searchText = sender.text, searchText.charactersArray.count >= 3 {
            guard let list = dataProvider.filterItemList(contains: searchText, for: outletId),
            let modelList = ProductMapper.transform(from: list, for: outletId) else {
                return
            }
            filtredItemList = modelList
            self.isLoading = true
        } else {
            filtredItemList = itemList
            self.isLoading = false
        }
        itemTableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldClose {
            self.dismiss(animated: true, completion: nil)
            shouldClose = false
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: self.showProductCard, sender: self.itemSearchField.text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showProductCard,
            let itemCardVC = segue.destination as? ItemCardVC,
            let searchedItem = sender as? String else {
                return
        }
        itemCardVC.delegate = itemCardDelegate
        itemCardVC.outletId = outletId
        itemCardVC.searchedItemName = searchedItem
        itemCardVC.dataProvider = dataProvider
        self.shouldClose = true
        
    }
}

extension ItemListVC: UITextFieldDelegate {
    //hide keyboard by press Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func numDonePressed() {
        itemSearchField.resignFirstResponder()
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
        itemSearchField.inputAccessoryView = toolbarDone
    }
}


//MARK: Table
extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 0 {
            if (!self.isLoading) {
                self.isLoading = true
                print("load new data (new \(currentPageOffset) items)")
                currentPageOffset += 20
                if let products = dataProvider.getShopItems(with: currentPageOffset, for: outletId),
                    let modelList = ProductMapper.transform(from: products, for: outletId) {
                    var indexPaths = [IndexPath]()
                    let currentCount: Int = filtredItemList.count
                    for i in 0..<modelList.count {
                        indexPaths.append(IndexPath(row: currentCount + i, section: 0))
                    }
                    // do the insertion
                    filtredItemList.append(contentsOf: modelList)
                    self.itemList.append(contentsOf: modelList)
                    // tell the table view to update (at all of the inserted index paths)
                    itemTableView.beginUpdates()
                    itemTableView.insertRows(at: indexPaths, with: .bottom)
                    itemTableView.endUpdates()
                }
                self.isLoading = false
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if filtredItemList.isEmpty {
            emptyList = true
            return 1
        }
        return filtredItemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filtredItemList.isEmpty {
            self.performSegue(withIdentifier: self.showProductCard, sender: self.itemSearchField.text)
            return
        }
        
        let item = filtredItemList[indexPath.row]
        self.dismiss(animated: true, completion: nil)
        delegate?.itemChoosen(productId: item.id)
        
        
        
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
        return UITableViewCell()
        
    }
}
