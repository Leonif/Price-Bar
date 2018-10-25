//
//  OutetListAdapter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/30/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class OutetListAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {

    var outlets: [OutletViewItem] = []

    public var onDidSelect: ((OutletViewItem) -> Void)?
    public var onError: ((String) -> Void)?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getRowsIn(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OutletCell = tableView.dequeueReusableCell(for: indexPath)
        let object = self.getOutlet(from: indexPath)

        cell.bind(outlet: object)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.getNumberOfSections()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.getOutlet(from: indexPath)
        self.onDidSelect?(object)
    }

}

extension OutetListAdapter {
    func getRowsIn(_ section: Int) -> Int {
        return outlets.count
    }

    func getOutlet(from indexPath: IndexPath) -> OutletViewItem {
        return outlets[indexPath.row]
    }

    func getNumberOfSections() -> Int {
        return 1
    }
}
