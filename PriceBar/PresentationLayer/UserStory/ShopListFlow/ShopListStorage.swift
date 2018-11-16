//
// Created by Leonid Nifantyev on 11/11/18.
// Copyright (c) 2018 LionLife. All rights reserved.
//

import Foundation

class ShopListStorage {
    var currentUserOutlet: OutletViewItem?
    func setCurrent(outlet: OutletViewItem) {
        self.currentUserOutlet = outlet
    }
}
