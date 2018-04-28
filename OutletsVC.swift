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

class OutletsVC: UIViewController, UIGestureRecognizerDelegate {
    var adapter: OutetListAdapter!
    var interactor: OutletListInteractor!
    
    lazy var searchBar: UISearchBar = {
        let s = UISearchBar(frame: CGRect.zero)
        s.placeholder = R.string.localizable.outlet_list_start_to_search_store()
        s.delegate = self
        return s
    }()
    
    let backButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        let icon = R.image.backButton()
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        
        return b
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
        
        self.setupNavigation()
        
        self.setupInteractor()
        
    }
    
    private func setupNavigation() {
        PriceBarStyles.grayBorderedRounded.apply(to: searchBar.textField)
        self.navigationItem.titleView = searchBar

        self.backButton.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
       
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func setBackIndicatorImage() {
        
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

    @objc
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



