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
    var delegate: Exchange!
    var hide: Bool = false
    
    
    @IBOutlet weak var itemSearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let itemList = ShopListModel().getShopItems(outletId: outletId) {
            self.itemList = itemList
            filtredItemList = self.itemList
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
        
        
        performSegue(withIdentifier: AppCons.showProductCard.rawValue, sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showProductCard.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            
                itemVC.delegate = self
                itemVC.outletId = outletId
            
        }
    }

    
}

extension ItemListVC: Exchange {
    func objectExchange(object: Any) {
        if let item = object as? ShopItem   {
            CoreDataService.data.addToShopListAndSaveStatistics(item)
            delegate.objectExchange(object: item)
            //self.dismiss(animated: true, completion: nil)
            hide = true
            
        }
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
        
        CoreDataService.data.addToShopListAndSaveStatistics(item)
        
        delegate.objectExchange(object: item)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell {
            
            let item = filtredItemList[indexPath.row]
            
            cell.itemNameLabel.text = item.name
            cell.itemPriceLabel.text = item.price.asLocaleCurrency
            return cell
        }
        
        return UITableViewCell()
    }
}
