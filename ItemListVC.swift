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
    var outletId: String = ""
    @IBOutlet weak var itemTableView: UITableView!
    var delegate: Exchange!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let itemList = ShopListModel().getShopItems(outletId: outletId) {
            self.itemList = itemList
        }
    
    
    
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newItemPressed(_ sender: Any) {
        
        
        performSegue(withIdentifier: AppCons.showProductCard.rawValue, sender: nil)
//        let um = ShopItemUom()
//        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Новая единица", quantity: 1.00, price: 0.00, category: "Неопредленно", uom: um, outletId: userOutlet.id, scanned: false))
//        shopTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showProductCard.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
            }
        }
    }

    
}

extension ItemListVC: Exchange {
    func objectExchange(object: Any) {
        if let item = object as? ShopItem   {
            CoreDataService.data.addToShopListAndSaveStatistics(item)
            
            delegate.objectExchange(object: item)
            self.dismiss(animated: true, completion: nil)
        }
    }
}



//MARK: Table
extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let item = itemList[indexPath.row]
        
        CoreDataService.data.addToShopListAndSaveStatistics(item)
        
        delegate.objectExchange(object: item)
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemListCell", for: indexPath) as? ItemListCell {
            
            let item = itemList[indexPath.row]
            
            cell.itemNameLabel.text = item.name
            cell.itemPriceLabel.text = item.price.asLocaleCurrency
            return cell
        }
        
        return UITableViewCell()
    }
}
