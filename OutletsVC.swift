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

    var outletService: OutletService?

    var delegate: OutletVCDelegate!
    @IBOutlet weak var outletTableView: UITableView!
    var outlets = [Outlet]()

    @IBOutlet weak var warningLocationView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.pb_startActivityIndicator(with: Strings.Common.outlet_loading.localized)
        outletService = OutletService()
        outletService?.outletList(completion: { result in
            self.view.pb_stopActivityIndicator()
            switch result {
            case let .success(outlets):
                self.outlets = OutletFactory.transform(from: outlets)
                DispatchQueue.main.async {
                    self.outletTableView.reloadData()
                }

            case let .failure(error):
                self.alert(title: "Ops", message: error.errorDescription)
            }
        })
    }

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Table
extension OutletsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outlets.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let outlet = outlets[indexPath.row]
        delegate.choosen(outlet: outlet)
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = outletTableView.dequeueReusableCell(withIdentifier: "OutletCell", for: indexPath) as? OutletCell {

            let outlet = outlets[indexPath.row]
            cell.configureCell(outlet: outlet)
            return cell
        }

        return UITableViewCell()
    }
}
