//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

struct ItemListModel {
    var product: String
    var currentPrice: Double
    var minPrice: Double
}




class ItemListVC: UIViewController {
    let showProductCard = "showProductCard"
    //var itemList = [ShopItem]()
    var itemList = [ItemListModel]()
    //var filtredItemList = [ShopItem]()
    var filtredItemList = [ItemListModel]()
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    var delegate: Exchange?
    var hide: Bool = false
    var dataProvider: DataProvider!
    
    var isLoading = false
    @IBOutlet weak var itemSearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.pb_startActivityIndicator(with: "Загрузка...")
    }
    
    var currentPageOffset = 0
    
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToNumPad()

        guard let products = dataProvider?.getShopItems(with: currentPageOffset, for: outletId),
            let itemList = convertItemList(from: products)
            else {
                alert(title: "Ops", message: "Нет товаров в базе")
                return
        }
        
        self.itemList = itemList
        
        filtredItemList = self.itemList.sorted { (item1, item2) in
            item1.currentPrice > item2.currentPrice
        }
        itemTableView.reloadData()

        self.view.pb_stopActivityIndicator()
    }
    
    
    func convertItemList(from products: [ShopItem]) -> [ItemListModel]? {
        var modellist = [ItemListModel]()
        
        for product in products {
            let price = dataProvider.getPrice(for: product.id, and: outletId)
            let minPrice = dataProvider.getMinPrice(for: product.id, and: outletId)
            let name = product.name
            modellist.append(ItemListModel(product: name, currentPrice: price, minPrice: minPrice))
        }
        return modellist
    }
    
    
    
    @IBAction func itemSearchFieldChanged(_ sender: UITextField) {
        if  let searchText = sender.text, searchText.charactersArray.count >= 3 {
            guard let list = dataProvider.filterItemList(contains: searchText, for: outletId),
            let modelList = convertItemList(from: list) else {
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
        if hide {
            self.dismiss(animated: true, completion: nil)
            hide = false
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newItemPressed(_ sender: Any) {
        performSegue(withIdentifier: showProductCard, sender: itemSearchField.text)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showProductCard, let itemVC = segue.destination as? ItemCardVC  {
            itemVC.delegate = self
            itemVC.outletId = outletId
            if let searchedItem = sender as? String  {
                itemVC.searchedItemName = searchedItem
            }
        }
    }
}

extension ItemListVC: Exchange {
    func objectExchange(object: Any) {
        if let item = object as? ShopItem   {
            dataProvider?.addToShopListAndSaveStatistics(item)
            print("From ItemList (objectExchange): addToShopListAndSaveStatistics - addToShopList")
            self.delegate?.objectExchange(object: item)
            hide = true
            
        }
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
                    let modelList = convertItemList(from: products) {
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
        return filtredItemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filtredItemList[indexPath.row]
        self.delegate?.objectExchange(object: item)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell {
            let item = filtredItemList[indexPath.row]
            cell.configureCell(item)
            return cell
        }
        return UITableViewCell()
    }
}
