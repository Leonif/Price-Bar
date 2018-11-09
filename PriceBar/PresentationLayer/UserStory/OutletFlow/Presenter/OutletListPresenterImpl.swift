//
//  OutletListInteractor.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

protocol OutletListOutput {
    func chosen(outlet: OutletViewItem)
}

protocol OutletListPresenter {
    func onSearchOutlet(with text: String)
    func onChosen(outlet: OutletViewItem)
    func viewDidLoadTrigger()
}

class OutletListPresenterImpl: OutletListPresenter {
    weak var view: OutletListView!
    var outletListOutput: OutletListOutput!
    var outletModel: OutletModel!
    var locationService: LocationService!
    var coordinates: (lat: Double, lon: Double)?

    private func updateOutletList(opOutlets: [OutletEntity]) {
        let outlets = opOutlets.map { OutletMapper.mapper(from: $0) }
        self.view.onOutletListFetched(outlets)
    }

    func viewDidLoadTrigger() {
        locationService.getCoords() // FIXME: remove duplication
        locationService.onStatusChanged = { [weak self] isAvalaible in
            if !isAvalaible {
                self?.view.onError(with: R.string.localizable.no_gps_access())
            } else {
                self?.locationService.getCoords() // FIXME: remove duplication
            }
        }

        locationService.onCoordinatesUpdated = { [weak self] coordinates  in
            self?.coordinates = coordinates
            self?.onGetOutletList()
        }
    }

    private func onGetOutletList() {
        guard let coordinates = self.coordinates else { return }
        self.view.showLoading(with: R.string.localizable.outlet_loading())
        self.outletModel?.outletListNearBy(coordinates: coordinates, completion: { [weak self] result in
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

    func onChosen(outlet: OutletViewItem) {
        self.outletListOutput.chosen(outlet: outlet)
    }

    func onSearchOutlet(with text: String) {
        guard let coordinates = self.coordinates else { return }
        self.outletModel.searchOutletList(with: text, nearby: coordinates) {  [weak self] result in
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
