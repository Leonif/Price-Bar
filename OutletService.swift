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
    //var nearestOutletDelegate: NearestOutletDelegate?
    var outletListDelegate: OutletListDelegate?
    var singleOutletCompletion: ((ResultType<OPOutletModel, OutletServiceError>) -> Void)?
    var outletListCompletion: ((ResultType<[OPOutletModel], OutletServiceError>) -> Void)?
    
    func nearestOutlet(completion: @escaping (ResultType<OPOutletModel, OutletServiceError>)->())  {
//        singleOutletCompletion = completion
//        locationService = LocationService(input: self)
//        let result = locationService.startReceivingLocationChanges()
//        switch result {
//        case let .failure(error):
//            print(error)
//            // User has not authorized access to location information.
//        default:
//            print("ok")
//        }
    }
    
    
    func outletList(completion: @escaping (ResultType<[OPOutletModel], OutletServiceError>)->())  {
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
                                        completion: @escaping (ResultType<[FQOutletModel], FoursqareProviderError>)->Void) {
        
        let foursquareProvider = FoursqareProvider()
        
        foursquareProvider.loadOultets(userCoordinate: coords, completed: { result in
            self.locationService?.stopLocationUpdating()
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        })
    }
    
    
//    func startLookingForOutletList(outletListDelegate: OutletListDelegate) {
//        self.outletListDelegate = outletListDelegate
//        locationService = LocationService(input: self)
//        _ = locationService?.startReceivingLocationChanges()
//    }
    
    

}


//extension OutletService: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print(status)
//        switch status {
//        case .authorizedWhenInUse:
//            _ = locationService?.startReceivingLocationChanges()
//        case .denied:
//            self.singleOutletCompletion?(ResultType.failure(.outletNotFound("Мы не можем найти магазины возле вас. Вы запретили следить за вашей позицией. Включите в настройках, чтобы использовать программу 😢")))
//        default:
//            print(status)
//        }
//    }
//
//
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let  userCoord = locations.last?.coordinate else {
//            fatalError("Coorddinate is not gotton")
//        }
//
//        let foursquareProvider = FoursqareProvider()
//
//
//        foursquareProvider.loadOultets(userCoordinate: userCoord, completed: { result in
//            self.locationService?.stopLocationUpdating()
//            switch result {
//            case let .success(outlets):
//                if let comletion = self.singleOutletCompletion {
//                    guard let fqOutlet = outlets.first else {
//                        fatalError("Outlet is not found")
//                    }
//                    let outlet = OutletFactory.mapper(from: fqOutlet)
//                    comletion(ResultType.success(outlet))
//                } else if let comletion = self.outletListCompletion {
//                    comletion(ResultType.success(OutletFactory.transform(from: outlets)))
//                } else {
//                    fatalError("Completion is not passed")
//                }
//            case let .failure(error):
//                fatalError(error.errorDescription)
//
//            }
//        })
//    }
//}


