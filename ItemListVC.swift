//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemListVC: UIViewController {
    
    
    
    let showProductCard = "showProductCard"
    
    var itemList = [ShopItem]()
    var filtredItemList = [ShopItem]()
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    var delegate: Exchange!
    var hide: Bool = false
    
    
    @IBOutlet weak var itemSearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(refresh)
        refresh.center = self.view.center
        refresh.run()
        
    }
    
    var refresh: RefreshView = {
        let r = RefreshView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        r.progressLabel.text = "Загрузка..."
        return r
    }()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToNumPad()
        
        //if let itemList = CoreDataService.data.getItemList(outletId: outletId) {
        if let itemList = CoreDataService.data.getShortItemList(outletId: outletId) {
            self.itemList = itemList
            filtredItemList = self.itemList
            itemTableView.reloadData()
        }
        refresh.stop()
        
    }
    
    
    @IBAction func itemSearchFieldChanged(_ sender: UITextField) {
        
        if sender.text != "" {
            let searchText = sender.text?.lowercased() ?? ""
            //filtredItemList = filtredItemList.filter { $0.name.lowercased().contains(searchText)}
            if let list = CoreDataService.data.filterItemList(itemName: searchText, for: outletId) {
                filtredItemList = list
            }
            
            
        } else {
            filtredItemList = itemList
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
            CoreDataService.data.addToShopListAndSaveStatistics(item)
            print("From ItemList (objectExchange): addToShopListAndSaveStatistics - addToShopList")
            delegate.objectExchange(object: item)
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
    
    func numDonePressed() {
        
        itemSearchField.resignFirstResponder()
        
    }
    
    
    func addDoneButtonToNumPad() {
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(numDonePressed))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        itemSearchField.inputAccessoryView = toolbarDone
    }
}



//MARK: Table
extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredItemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let item = filtredItemList[indexPath.row]
        
        delegate.objectExchange(object: item)
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
