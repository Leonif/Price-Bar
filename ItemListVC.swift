//
//  ItemListVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemListVC: UIViewController {

    var itemList = [ShopItem]()
    var filtredItemList = [ShopItem]()
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var refreshView: RefreshView!
    var delegate: Exchange!
    var hide: Bool = false
    
    
    @IBOutlet weak var itemSearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addDoneButtonToNumPad()
        //refreshView.isHidden = false
        //refreshView.activityIndicator.startAnimating()
        if let itemList = CoreDataService.data.getItemList(outletId: outletId) {
            self.itemList = itemList
            filtredItemList = self.itemList
//            refreshView.activityIndicator.stopAnimating()
//            refreshView.isHidden = true
            itemTableView.reloadData()
            
            
        }
        
    }
    
    
    @IBAction func itemSearchFieldChanged(_ sender: UITextField) {
        
        if sender.text != "" {
           filtredItemList = filtredItemList.filter { $0.name.lowercased().contains(sender.text?.lowercased() ?? "")}
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
        
        
        performSegue(withIdentifier: AppCons.showProductCard.rawValue, sender: itemSearchField.text)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showProductCard.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            
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
    //hide keyboard by press ENter
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
        
        //print("From ItemList (didSelect): addToShopListAndSaveStatistics - addToShopList")
        //CoreDataService.data.addToShopListAndSaveStatistics(item)
        
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
