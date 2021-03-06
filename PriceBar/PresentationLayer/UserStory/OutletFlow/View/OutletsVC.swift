//
//  OutletsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit
import CoreLocation

protocol OutletListView: BaseView {
    func onOutletListFetched(_ outlets: [OutletViewItem])
}

class OutletsVC: UIViewController, OutletListView, UIGestureRecognizerDelegate {
    var adapter: OutetListAdapter!
    var presenter: OutletListPresenter!
    @IBOutlet weak var tableView: UITableView!

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect.zero)
        searchBar.placeholder = R.string.localizable.outlet_list_start_to_search_store()
        searchBar.delegate = self
        return searchBar
    }()

    let backButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        let icon = R.image.backButton()
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self.adapter
        self.tableView.dataSource = self.adapter

        // For registering nib files
        tableView.register(OutletCell.self)

        self.adapter.onDidSelect = { [weak self] outlet in
            self?.presenter.onChosen(outlet: outlet)
            self?.close()
        }

        self.setupNavigation()
        self.presenter.viewDidLoadTrigger()

    }

    private func setupNavigation() {
        PriceBarStyles.grayBorderedRounded.apply(to: searchBar.textField)
        self.navigationItem.titleView = searchBar

        self.backButton.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    func onOutletListFetched(_ outlets: [OutletViewItem]) {
        self.adapter.outlets = outlets
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        self.presenter.onSearchOutlet(with: text)
    }
}
