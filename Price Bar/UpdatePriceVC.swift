//
//  UpdatePriceVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/8/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class UpdatePriceVC: UIViewController {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    public var dataSource: [StatisticModel]!
    var adapter: UpdatePriceAdapter!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var onSavePrice: ((Double)->())? = nil
    
    var productName: String!
    var price: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter = UpdatePriceAdapter(tableView: self.tableView, dataSource: self.dataSource)
        self.addToolBar(textField: priceTextField)
        self.priceTextField.text = "\(self.price)"
        self.productNameLabel.text = productName
        
        PriceBarStyles.grayBorderedRoundedView.apply(to: self.saveButton)
        
        self.priceTextField.delegate = self
    }
    
    @IBAction func savePriceTapped(_ sender: Any) {
        guard let price = self.priceTextField.text?.numberFormatting() else {
            return
        }
        
        self.onSavePrice?(price)
        self.dismiss(animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}









