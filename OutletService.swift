//
//  OutletService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreLocation

protocol OutletListDelegate {
    func list(result: ResultType<[OPOutletModel], OutletServiceError>)
}

protocol NearestOutletDelegate {
    func nearest(result: ResultType<OPOutletModel, OutletServiceError>)
}

enum OutletServiceError: Error {
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
    var outletListDelegate: OutletListDelegate?
    var singleOutletCompletion: ((ResultType<OPOutletModel, OutletServiceError>) -> Void)?
    var outletListCompletion: ((ResultType<[OPOutletModel], OutletServiceError>) -> Void)?

    override init() {
        super.init()
        locationService = LocationService()
    }

    func nearestOutlet(completion: @escaping (ResultType<OPOutletModel, OutletServiceError>)->Void) {
        singleOutletCompletion = completion
        locationService.getCoords { result in
            switch result {
            case let .failure(error):
                print(error)
                self.singleOutletCompletion?(ResultType.failure(.other(error.errorDescription)))
            case let .success(coords):
                self.outletListFromProvider(for: coords, completion: { result in
                    switch result {
                    case let .success(fqoutlets):
                        if let fqoutlet = fqoutlets.first {
                            self.singleOutletCompletion?(ResultType.success(OutletFactory.mapper(from: fqoutlet)))
                        }
                    case let .failure(error):
                        // need to hadle different cases of error from provider
                        self.singleOutletCompletion?(ResultType.failure(.other(error.errorDescription)))
                    }
                })
            }
        }
    }

    func outletList(completion: @escaping (ResultType<[OPOutletModel], OutletServiceError>)->Void) {
        outletListCompletion = completion

        locationService.getCoords { result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(coords):
                self.outletListFromProvider(for: coords, completion: { result in
                    switch result {
                    case let .success(fqoutlets):
                        self.outletListCompletion?(ResultType.success(OutletFactory.transform(from: fqoutlets)))
                    case let .failure(error):
                        self.outletListCompletion?(ResultType.failure(.other(error.errorDescription)))
                    }
                })
            }
        }
    }

    private func outletListFromProvider(for coords: CLLocationCoordinate2D,
                                        completion: @escaping (ResultType<[FQOutletModel], FoursqareProviderError>) -> Void) {
        let foursquareProvider = FoursqareProvider()
        foursquareProvider.loadOultets(userCoordinate: coords, completed: { result in
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        })
    }
}
