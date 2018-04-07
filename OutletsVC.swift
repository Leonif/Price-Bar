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
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar(frame: CGRect.zero)
        s.placeholder = R.string.localizable.outlet_list_start_to_search_store()
        s.delegate = self
        return s
    }()

    var delegate: OutletVCDelegate!
    @IBOutlet weak var outletTableView: UITableView!

    @IBOutlet weak var warningLocationView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.adapter = OutetListAdapter(tableView: self.outletTableView)
        self.adapter.onDidSelect = { [weak self] outlet in
            self?.delegate.choosen(outlet: outlet)
            self?.close()
        }
        
        self.navigationItem.prompt = R.string.localizable.outlet_list_search()
        self.navigationItem.titleView = searchBar
        
        
        
        self.setupInteractor()
        
    }
    
    func setupInteractor() {
        self.interactor = OutletListInteractor()
        self.view.pb_startActivityIndicator(with: R.string.localizable.outlet_loading())

        self.interactor.getOutletList()
        self.interactor.onOutletListFetched = { [weak self] outlets in
            self?.adapter.outlets = outlets.map { OutletMapper.mapper(from: $0) }
        }
        self.interactor.onFetchingCompleted = { [weak self] in
            self?.view.pb_stopActivityIndicator()
        }
        self.interactor.onFetchingError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.alert(message: errorMessage)
            }
            
        }
    }
    
    

    @IBAction func backPressed(_ sender: Any) {
        self.close()
    }
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension OutletsVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        
        self.view.endEditing(true)
        
        self.interactor.searchOutlet(with: text)
    }
}



