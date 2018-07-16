//
//  OutletListInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol OutletListOutput {
    func choosen(outlet: Outlet)
}




protocol OutletListPresenter {
    func onGetOutletList()
    func onSearchOutlet(with text: String)
    func onChoosen(outlet: Outlet)
}


class OutletListPresenterImpl: OutletListPresenter {
    weak var view: OutletListView!
    var outletListOutput: OutletListOutput!
    var outletService: OutletService!
    
    private func updateOutletList(opOutlets: [OPOutletModel]) {
        let outlets = opOutlets.map { OutletMapper.mapper(from: $0) }
        self.view.onOutletListFetched(outlets)
        
    }
    
    func onGetOutletList() {
        self.view.showLoading(with: R.string.localizable.outlet_loading())
        self.outletService?.outletList(completion: { [weak self] result in
            self?.view.hideLoading()
            guard let `self` = self else { return }
            switch result {
            case let .success(opOutlets):
                self.updateOutletList(opOutlets: opOutlets)
            case let .failure(error):
                self.view.onError(with: error.localizedDescription)
            }
        })
    }
    

    func onChoosen(outlet: Outlet) {
        self.outletListOutput.choosen(outlet: outlet)
    }
    
    func onSearchOutlet(with text: String) {
        self.outletService.searchOutletList(with: text) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case let .success(opOutlets):
                self.updateOutletList(opOutlets: opOutlets)
            case let .failure(error):
                self.view.onError(with: error.errorDescription)
            }
        }
    }
    
}
