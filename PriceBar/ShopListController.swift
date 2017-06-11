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
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        shopTableView.addGestureRecognizer(longpress)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shopTableView.reloadData()
    }
    
    

    @IBAction func quantityPlusPressed(_ sender: UIButton) {
        
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                if let shp = shopList.getItem(index: indexPath) {
                    shp.quantity += 0.01
                    shopTableView.reloadData()
                }
            }
        }
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
        
    }
    
    @IBAction func quantityMinesPressed(_ sender: UIButton) {
        
        if let cell = sender.superview?.superview?.superview as? ShopItemCell {
            if let indexPath = shopTableView.indexPath(for: cell) {
                if let shp = shopList.getItem(index: indexPath) {
                    if shp.quantity - 0.01 >= 0 {
                        shp.quantity -= 0.01
                        
                    } else {
                        shp.quantity = 0.0
                    }
                }
                shopTableView.reloadData()
            }
        }
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
    }
    
    func loadData() {
        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Помидоры", quantity: 0.650, price: 39.6, category: "Овощи, фрукты"))
        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Огурцы", quantity: 0.650, price: 39.6, category: "Овощи, фрукты"))
        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Французская булка", quantity: 0.650, price: 39.6, category: "Пекарня"))
        
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
    }
    
    @IBAction func newItemPressed(_ sender: Any) {
        
        shopList.append(item: ShopItem(id: UUID().uuidString, name: "Новая единица", quantity: 1.00, price: 0.00, category: "Неопредленно"))
        
        shopTableView.reloadData()
        
        
    }
    
}


protocol Exchange {
    func itemChanged(item: ShopItem)
}


extension ShopListController: Exchange {
    
    func itemChanged(item: ShopItem) {
        shopList.change(item: item)
        totalLabel.text = "Итого: \(shopList.total.asLocaleCurrency)"
    }
    
}


//MARK: Drag cells into other category and between each others
extension ShopListController {
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: shopTableView)
        let indexPath = shopTableView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = shopTableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot = snapshopOfCell(inputView: cell!)
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                shopTableView.addSubview(My.cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        case UIGestureRecognizerState.changed:
            
            if var center = My.cellSnapshot?.center {
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    //change places
                    if let a = shopList.getItem(index: indexPath!), let b = shopList.getItem(index: Path.initialIndexPath!) {
                    
                        if let c = b.copy() as? ShopItem {
                            
                            c.category = a.category
                            shopList.remove(item: b)
                            shopList.append(item: c)
                            
                            //  shopTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                            Path.initialIndexPath = indexPath
                            shopTableView.reloadData()
                            
                        }
                    }
                }
            }
            
            
        default:
            if let pIndex = Path.initialIndexPath, let cell = shopTableView.cellForRow(at:pIndex) {
                cell.isHidden = false
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = cell.center
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = shopList.getItem(index: indexPath) {
                shopTableView.beginUpdates()
                
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section - 1)
                shopTableView.deleteRows(at: [indexPath], with: .fade)
                //shopTableView.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.automatic)
                
                
                
                shopList.remove(item: item)
                
                shopTableView.endUpdates()
                
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopList.rowsIn(section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: AppCons.showProductCard.rawValue, sender: shopList.getItem(index: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppCons.showProductCard.rawValue, let itemVC = segue.destination as? ItemCardVC  {
            if let item = sender as? ShopItem {
                itemVC.item = item
                itemVC.delegate = self
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = shopTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ShopItemCell {
            
            if let shp = shopList.getItem(index: indexPath) {
                cell.configureCell(shopItem: shp)
                return cell
            }
            
        }
        
        
        
        return UITableViewCell()
    }
}

