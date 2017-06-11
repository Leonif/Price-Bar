//
//  ItemCardVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/10/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class ItemCardVC: UIViewController {
    
    
    var item: ShopItem?
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var delegate: Exchange!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTitle.delegate = self
        itemPrice.delegate = self

        if let item = item {
            itemTitle.text = item.name
            itemPrice.text = String(format:"%.2f", item.price)
            categoryLabel.text = item.category
        }
    }

   
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        
        item?.name = itemTitle.text!
        item?.price = (itemPrice.text?.double)!
        delegate.itemChanged(item: item!)
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ItemCardVC: UITextFieldDelegate {
    //hide keyboard by press ENter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

