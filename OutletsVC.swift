//
//  OutletsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit
import CoreLocation

protocol OutletVCDelegate {
    func choosen(outlet: Outlet)
}

class OutletsVC: UIViewController {
    var adapter: OutetListAdapter!
    var interactor: OutletListInteractor!

    var delegate: OutletVCDelegate!
    @IBOutlet weak var outletTableView: UITableView!

    @IBOutlet weak var warningLocationView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.adapter = OutetListAdapter(tableView: outletTableView)
        self.adapter.onDidSelect = { [weak self] outlet in
            self?.delegate.choosen(outlet: outlet)
            self?.close()
        }
        
        self.setupInteractor()
        
    }
    
    func setupInteractor() {
        self.interactor = OutletListInteractor()
        self.view.pb_startActivityIndicator(with: Strings.Common.outlet_loading.localized)
        self.interactor.getOutletList()
        self.interactor.onOutletListFetched = { [weak self] outlets in
            self?.adapter.outlets = OutletMapper.transform(from: outlets)
        }
        self.interactor.onFetchingCompleted = { [weak self] in
            self?.view.pb_stopActivityIndicator()
        }
        self.interactor.onFetchingError = { [weak self] errorMessage in
            self?.alert(title: "Ops", message: errorMessage)
        }
    }
    
    

    @IBAction func backPressed(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
