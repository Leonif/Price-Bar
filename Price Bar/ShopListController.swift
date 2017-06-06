//
//  ShopListController.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ShopListController: UIViewController {

    var shopList = ShopListModel()
    
    @IBOutlet weak var shopTableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        
    }
    @IBAction func quantityPlusPressed(_ sender: UIButton) {
        
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                let shp = shopList.getItem(index: indexPath)
                shp.quantity += 0.01
                shopTableView.reloadData()
            }
        }
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
        
    }
    
    @IBAction func quantityMinesPressed(_ sender: UIButton) {
        
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                let shp = shopList.getItem(index: indexPath)
                if (shp.quantity - 0.01) >= 0 {
                    shp.quantity -= 0.01
                    
                } else {
                    shp.quantity = 0.0
                }
                shopTableView.reloadData()
            }
        }
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
    }
    
    func loadData() {
        shopList.append(item: ShopItem(id: "1", name: "Помидоры", quantity: 0.650, price: 39.6, category: "Овощи, фрукты"))
        shopList.append(item: ShopItem(id: "2", name: "Огурцы", quantity: 0.650, price: 39.6, category: "Овощи, фрукты"))
        shopList.append(item: ShopItem(id: "3", name: "Французская булка", quantity: 0.650, price: 39.6, category: "Пекарня"))
        
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
    }
    
    @IBAction func newItemPressed(_ sender: Any) {
        
        shopList.append(item: ShopItem(id: "0", name: "Новая единица", quantity: 0.00, price: 0.00, category: "Неопредленно"))
        
        shopTableView.reloadData()
        
        
    }
    
}




//MARK: Table
extension ShopListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headeView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView {
            
            headeView.categoryLabel.text = shopList.headerString(for: section)
            return headeView
        }
        
        
        
        
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shopList.sectionCount
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shopList.headerString(for: section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopList.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = shopTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            let shp = shopList.getItem(index: indexPath)
            
            cell.configureCell(shopItem: shp)
            
            return cell
            
        }
        
        
        
        return UITableViewCell()
    }
}

