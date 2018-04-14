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
    var data: DataStorage!
    var adapter: UpdatePriceAdapter!
    @IBOutlet weak var saveButton: UIButton!
    
    var interactor: UpdatePriceInteractor!
    var repository: Repository!
    
    @IBOutlet weak var tableView: UITableView!
    var onSavePrice: (() -> Void)? = nil
    
    var productId: String!
    var price: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactor = UpdatePriceInteractor(repository: self.repository)
        self.updateStatistics { [weak self] in
            guard let `self` = self else { return }

            self.adapter = UpdatePriceAdapter(tableView: self.tableView, dataSource: self.dataSource)
            self.tableView.reloadData()
        }
        self.addToolBar(textField: self.priceTextField)
        PriceBarStyles.grayBorderedRoundedView.apply(to: self.saveButton)
        self.priceTextField.delegate = self
    }
    
    
    func updateStatistics(completin: @escaping () -> ()) {
        
        self.interactor.getPriceStatistics(for: productId, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(statistic):
                
                guard let outlet = self.data.outlet else {
                    fatalError()
                }
                
                let price = self.interactor.getPrice(for: self.productId, in: outlet.id)
                self.priceTextField.text = "\(price)"
                
                
                self.dataSource = statistic
                let productName = self.interactor.getProductName(for: self.productId)
                self.productNameLabel.text = productName
                completin()
                
                
//                data.vc.present(vc, animated: true)
            case let .failure(error):
                self.alert(message: error.message)
            }
        })
        
    }
    
    
    
    @IBAction func savePriceTapped(_ sender: Any) {
        guard let price = self.priceTextField.text?.numberFormatting() else {
            return
        }
        if self.price != price && price != 0  {
            guard let outlet = self.data.outlet else {
                    fatalError()
            }
            
            self.interactor.updatePrice(for: self.productId, price: price, outletId: outlet.id)
            self.onSavePrice?()
//            self.interactor.reloadProducts(outletId: outlet.id)
            
            self.close()
        } else {
            self.alert(title: R.string.localizable.thank_you(),
                       message: R.string.localizable.price_update_not_changed(),
                       okAction: {
                        self.close()
            })
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    func close() {
        self.dismiss(animated: true)
    }
}









