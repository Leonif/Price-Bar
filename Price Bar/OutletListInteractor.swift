//
//  OutletListInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class OutletListInteractor {
    
    private var outletService: OutletService!
    var onFetchedBatch: (([OPOutletModel])->())? = nil
    var onFetchingError: ((String)->())? = nil
    var onFetchingCompleted: (()->())? = nil
    
    init() {
        self.outletService = OutletService()
    }

    func getOutletList() {
        self.outletService?.outletList(completion: { [weak self] result in
            guard let `self` = self else { return }
            
            self.onFetchingCompleted?()
            switch result {
            case let .success(outlets):
                self.onFetchedBatch?(outlets)
            case let .failure(error):
                self.onFetchingError?(error.localizedDescription)
            }
        })
    }
}
