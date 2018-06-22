//
//  UpdatePriceVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/8/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

protocol UpdatePriceView: BaseView {
    func onError(with message: String)
    func onGetProductInfo(price: Double, name: String, uomName: String)
    func onGetStatistics(statistic: [StatisticModel])
}

class UpdatePriceVC: UIViewController, UpdatePriceView {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    public var dataSource: [StatisticModel]!

    var adapter: UpdatePriceAdapter!
    @IBOutlet weak var saveButton: UIButton!
    
    var presenter: UpdatePricePresenter!
    
    @IBOutlet weak var tableView: UITableView!

    
    var productId: String!
    var outletId: String!
    var price: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addToolBar(textField: self.priceTextField)
        PriceBarStyles.grayBorderedRounded.apply(to: self.priceTextField, self.saveButton)
        self.priceTextField.delegate = self
        self.presenter.onGetProductInfo(for: productId, and: outletId)
    }
    
    func onGetStatistics(statistic: [StatisticModel]) {
        self.dataSource = statistic
        self.adapter = UpdatePriceAdapter(tableView: self.tableView, dataSource: self.dataSource)
        self.tableView.reloadData()
    }
    
    func onGetProductInfo(price: Double, name: String, uomName: String) {
        self.priceTextField.text = "\(price)"
        self.price = price
        self.productNameLabel.text = name
        self.uomLabel.text = uomName
        
        self.presenter.onGetPriceStatistics(for: productId)
    }
    
    func onError(with message: String) {
        self.alert(message: message)
    }
    
    @IBAction func savePriceTapped(_ sender: Any) {
        guard let price = self.priceTextField.text?.numberFormatting() else {
            return
        }
        self.presenter.onSavePrice(for: productId, for: outletId, with: price, and: self.price)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.dismiss(animated: true)
    }
}
