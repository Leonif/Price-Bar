//
//  GooglePlacesOutletModelImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 8/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

// MARK: - Google Places provider
class GooglePlacesOutletModelImpl: OutletModel {
    var googlePlacesProvider: GooglePlacesProvider!
//    var singleOutletCompletion: ((ResultType<OPOutletModel, OutletModelError>) -> Void)?
//    var outletListCompletion: ((ResultType<[OPOutletModel], OutletModelError>) -> Void)?
    
    init() {
        self.googlePlacesProvider = GooglePlacesProvider()
    }
    
    func getOutlet(with outletId: String, completion: @escaping OutletResultType) {
        self.googlePlacesProvider.getOutlet(for: outletId) { (gmsPlace) in
            completion(ResultType.success(OPOutletModel(id: gmsPlace.placeID,
                                                        name: gmsPlace.name,
                                                        address: gmsPlace.formattedAddress!,
                                                        distance: 0.0) ))
        }
    }
    func nearestOutlet(nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletResultType) {
//        self.singleOutletCompletion = completion
        
        self.googlePlacesProvider.getNearestOutlet { (gmsPlaceLikelihood) in
            completion(ResultType.success(OPOutletModel(id: gmsPlaceLikelihood.place.placeID,
                                                                          name: gmsPlaceLikelihood.place.name,
                                                                          address: gmsPlaceLikelihood.place.formattedAddress!,
                                                                          distance: 0.0)))
        }
        
    }
    
    
    func outletList(nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType) {
//        outletListCompletion = completion
        self.googlePlacesProvider.getNearestOutletList { (gmsPlaceLikelihoods) in
            let outlets = gmsPlaceLikelihoods.map { OPOutletModel(id: $0.place.placeID,
                                                                  name: $0.place.name,
                                                                  address: $0.place.formattedAddress!,
                                                                  distance: 0.0) }
            completion(ResultType.success(outlets))
        }
    }
    
    func searchOutletList(with text: String, nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType) {
        self.googlePlacesProvider.getOutlet(with: text) { (gmsAutocompletePredictions) in
            let outlets = gmsAutocompletePredictions.map { OPOutletModel(id: $0.placeID!,
                                                                         name: $0.attributedFullText.string,
                                                                         address: "",
                                                                         distance: 0.0) }
            completion(ResultType.success(outlets))
        }
    }
}
