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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let itemList = ShopListModel().getShopItems(outletId: outletId) {
            self.itemList = itemList
        }
    
    
    
    }
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
