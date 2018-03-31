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
    var outletListDelegate: OutletListDelegate?
    var singleOutletCompletion: ((ResultType<OPOutletModel, OutletServiceError>) -> Void)?
    var outletListCompletion: ((ResultType<[OPOutletModel], OutletServiceError>) -> Void)?

    var location: CLLocationCoordinate2D? = nil
    
    
    override init() {
        super.init()
        self.locationService = LocationService()
        self.foursquareProvider = FoursqareProvider()
    }
    
    
    func getOutlet(with outletId: String, completion: @escaping OutletResultType) {
        let foursquareProvider = FoursqareProvider()
        foursquareProvider.getOutlet(with: outletId) { (result) in
            switch result {
            case let .success(fqoutlet):
                completion(ResultType.success(OutletMapper.mapper(from: fqoutlet)))
            case let .failure(error):
                // TODO: need to hadle different cases of error from provider
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
                        self.outletListCompletion?(ResultType.success(OutletMapper.transform(from: fqoutlets)))
                    case let .failure(error):
                        self.outletListCompletion?(ResultType.failure(.other(error.errorDescription)))
                    }
                })
            }
        }
    }
    
    
    func searchOutletList(with text: String, completion: @escaping OutletListResultType) {
        self.locationService.getCoords { [weak self] (result) in
            
            guard let `self` = self else { return }
            
            switch result {
            case let .failure(error):
                self.outletListCompletion?(ResultType.failure(OutletServiceError.other("")))
            case let .success(coords):
            
                self.searchOutletListFromProvider(with: text, for: coords, completion: { (result) in
                    switch result {
                    case let .success(fqoutlets):
                        completion(ResultType.success(OutletMapper.transform(from: fqoutlets)))
                        
                    case let .failure(error):
                        completion(ResultType.failure(.other(error.errorDescription)))
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
