//
//  OutletService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreLocation

typealias OutletResultType = (ResultType<OPOutletModel, OutletServiceError>) -> Void
typealias OutletListResultType = (ResultType<[OPOutletModel], OutletServiceError>) -> Void



protocol OutletListDelegate {
    func list(result: ResultType<[OPOutletModel], OutletServiceError>)
}

protocol NearestOutletDelegate {
    func nearest(result: ResultType<OPOutletModel, OutletServiceError>)
}



public enum OutletServiceError: Error {
    case outletNotFound(String)
    case userDeniedLocation(String)
    case foursqareDoesntResponce(String)
    case wrongURL(String)
    case parseError(String)
    case other(String)

    var errorDescription: String {
        switch self {
        case let .outletNotFound(description),
             let .userDeniedLocation(description),
             let .foursqareDoesntResponce(description),
             let .wrongURL(description),
             let .parseError(description),
             let .other(description):
            return description
        }
    }
}

class OutletService: NSObject {
    var locationService: LocationService!
    var foursquareProvider: FoursqareProvider!
    var googlePlacesProvider: GooglePlacesProvider!
    
    
    var outletListDelegate: OutletListDelegate?
    var singleOutletCompletion: ((ResultType<OPOutletModel, OutletServiceError>) -> Void)?
    var outletListCompletion: ((ResultType<[OPOutletModel], OutletServiceError>) -> Void)?

    var location: CLLocationCoordinate2D? = nil
    
    
    override init() {
        super.init()
        self.locationService = LocationService()
        self.foursquareProvider = FoursqareProvider()
        self.googlePlacesProvider = GooglePlacesProvider()
    }
    
    
    
}


// MARK: - Google Places provider
extension OutletService {
    
    //    func getOutlet(with outletId: String, completion: @escaping OutletResultType) {
    //
    //        self.googlePlacesProvider.getOutlet(for: outletId) { (gmsPlace) in
    //            completion(ResultType.success(OPOutletModel(id: gmsPlace.placeID,
    //                                                        name: gmsPlace.name,
    //                                                        address: gmsPlace.formattedAddress!,
    //                                                        distance: 0.0) ))
    //        }
    //
    //    }
    
    
    //    func nearestOutlet(completion: @escaping OutletResultType) {
    //        self.singleOutletCompletion = completion
    //
    //        self.googlePlacesProvider.getNearestOutlet { (gmsPlaceLikelihood) in
    //            self.singleOutletCompletion?(ResultType.success(OPOutletModel(id: gmsPlaceLikelihood.place.placeID,
    //                                                                          name: gmsPlaceLikelihood.place.name,
    //                                                                          address: gmsPlaceLikelihood.place.formattedAddress!,
    //                                                                          distance: 0.0)))
    //        }
    //
    //    }
    

    //    func outletList(completion: @escaping OutletListResultType) {
    //        outletListCompletion = completion
    //        self.googlePlacesProvider.getNearestOutletList { (gmsPlaceLikelihoods) in
    //            let outlets = gmsPlaceLikelihoods.map { OPOutletModel(id: $0.place.placeID,
    //                                                      name: $0.place.name,
    //                                                      address: $0.place.formattedAddress!,
    //                                                      distance: 0.0) }
    //            self.outletListCompletion?(ResultType.success(outlets))
    //        }
    //    }
    
    
    //    func searchOutletList(with text: String, completion: @escaping OutletListResultType) {
    //
    //        self.googlePlacesProvider.getOutlet(with: text) { (gmsAutocompletePredictions) in
    //            let outlets = gmsAutocompletePredictions.map { OPOutletModel(id: $0.placeID!,
    //                                                           name: $0.attributedFullText.string,
    //                                                           address: "",
    //                                                           distance: 0.0) }
    //
    //            completion(ResultType.success(outlets))
    //        }
    //
    //
    //    }

    
    
}




// MARK: - Foursqare provider
extension OutletService {
        func searchOutletList(with text: String, completion: @escaping OutletListResultType) {
            self.locationService.getCoords { [weak self] (result) in
                guard let `self` = self else { return }
    
                switch result {
                case let .failure(error):
                    self.outletListCompletion?(ResultType.failure(OutletServiceError.other(error.errorDescription)))
                case let .success(coords):
    
                    self.searchOutletListFromProvider(with: text, for: coords, completion: { (result) in
                        switch result {
                        case let .success(fqoutlets):
    
                            let outlets = fqoutlets.map { OutletMapper.mapper(from: $0) }
    
                            completion(ResultType.success(outlets))
    
                        case let .failure(error):
                            completion(ResultType.failure(.other(error.errorDescription)))
                        }
                    })
    
                }
            }
        }

    func getOutlet(with outletId: String, completion: @escaping OutletResultType) {
        let foursquareProvider = FoursqareProvider()
        foursquareProvider.getOutlet(with: outletId) { (result) in
            switch result {
            case let .success(fqoutlet):
                completion(ResultType.success(OutletMapper.mapper(from: fqoutlet)))
            case let .failure(error):
                completion(ResultType.failure(.other(error.errorDescription)))
            }
        }
    }
    
    func nearestOutlet(completion: @escaping OutletResultType) {
        self.singleOutletCompletion = completion
        self.locationService.getCoords { result in
            switch result {
            case let .failure(error):
                self.singleOutletCompletion?(ResultType.failure(.other(error.errorDescription)))
            case let .success(coords):
                self.outletListFromProvider(for: coords, completion: { result in
                    switch result {
                    case let .success(fqoutlets):
                        if let fqoutlet = fqoutlets.first {
                            self.singleOutletCompletion?(ResultType.success(OutletMapper.mapper(from: fqoutlet)))
                        }
                    case let .failure(error):
                        // need to hadle different cases of error from provider
                        self.singleOutletCompletion?(ResultType.failure(.other(error.errorDescription)))
                    }
                })
            }
        }
    }
    
    
    
    func outletList(completion: @escaping OutletListResultType) {
        outletListCompletion = completion
        
        self.locationService.getCoords { [weak self] result in
            
            guard let `self` = self else { return }
            
            switch result {
            case let .failure(error):
                print(error)
            case let .success(coords):
                self.outletListFromProvider(for: coords, completion: { [weak self] result in
                    
                    guard let `self` = self else { return }
                    
                    switch result {
                    case let .success(fqoutlets):
                        
                        let outlets = fqoutlets.map { OutletMapper.mapper(from: $0) }
                        
                        self.outletListCompletion?(ResultType.success(outlets))
                    case let .failure(error):
                        self.outletListCompletion?(ResultType.failure(.other(error.errorDescription)))
                    }
                })
            }
        }
    }
    
    
    private func searchOutletListFromProvider(with text: String, for coords: CLLocationCoordinate2D, completion: @escaping ForsqareOutletList) {
        
        self.foursquareProvider.searchOutlet(with: text, userCoordinate: coords) { (result) in
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        }
    }
    
    private func outletListFromProvider(for coords: CLLocationCoordinate2D,
                                        completion: @escaping (ResultType<[FQOutletModel], FoursqareProviderError>) -> Void) {
        
        self.foursquareProvider.loadOultets(userCoordinate: coords, completion: { result in
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        })
    }
    
    
}








