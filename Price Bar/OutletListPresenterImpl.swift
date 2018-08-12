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
    var outletModel: OutletModel!
    var locationModel: LocationService!
    var currentCoords: (lat: Double, lon: Double) = (0.0, 0.0)
    
    private func updateOutletList(opOutlets: [OPOutletModel]) {
        let outlets = opOutlets.map { OutletMapper.mapper(from: $0) }
        self.view.onOutletListFetched(outlets)
        
    }
    
    
    init() {
        self.subscribeOnGeoPosition()
        self.locationModel.getCoords()
        
    }
    
    func onGetOutletList() {
        self.view.showLoading(with: R.string.localizable.outlet_loading())
        self.outletModel?.outletList(nearby: self.currentCoords, completion: { [weak self] result in
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
    
    func subscribeOnGeoPosition() {
        self.locationModel.onCoordinatesUpdated = { [weak self] coordinates in
            self?.currentCoords = coordinates
        }
        
        self.locationModel.onError = { [weak self] errorMessage in
            self?.view.onError(with: errorMessage)
        }
        
        self.locationModel.onStatusChanged = { [weak self] isAllowed in
            if isAllowed {
                self?.locationModel.getCoords()
            } else {
                self?.view.onError(with: "Geo position is not availabel")
            }
        }
        
    }

    func onChoosen(outlet: Outlet) {
        self.outletListOutput.choosen(outlet: outlet)
    }
    
    func onSearchOutlet(with text: String) {
        self.outletModel.searchOutletList(with: text, nearby: self.currentCoords) { [weak self] result in
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
