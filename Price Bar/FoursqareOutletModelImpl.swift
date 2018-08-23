//
//  FoursqareOUtletModelImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 8/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class FoursqareOutletModelImpl: OutletModel {
    var foursquareProvider: FoursquareProvider!
    
    init(_ foursquareProvider: FoursquareProvider) {
        self.foursquareProvider = foursquareProvider
    }
    
    
    func searchOutletList(with text: String, nearby coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType) {
        self.searchOutletListFromProvider(with: text, for: coordinates, completion: { (result) in
            switch result {
            case let .success(outlets):
                
//                let outlets = fqoutlets.map { OutletMapper.mapper(from: $0) }
                
                completion(ResultType.success(outlets))
                
            case let .failure(error):
                completion(ResultType.failure(.other(error.errorDescription)))
            }
        })
    }
    
    func getOutlet(with outletId: String, completion: @escaping OutletResultType) {
        let foursquareProvider = FoursquareProvider()
        foursquareProvider.getOutlet(with: outletId) { (result) in
            switch result {
            case let .success(fqoutlet):
                completion(ResultType.success(fqoutlet))
            case let .failure(error):
                completion(ResultType.failure(.other(error.errorDescription)))
            }
        }
    }
    
    func nearestOutletNearBy(coordinates: (lat: Double, lon: Double), completion: @escaping OutletResultType) {
        self.outletListFromProvider(for: coordinates, completion: { result in
            switch result {
            case let .success(fqoutlets):
                if let fqoutlet = fqoutlets.first {
                    completion(ResultType.success(fqoutlet))
                }
            case let .failure(error):
                completion(ResultType.failure(.other(error.errorDescription)))
            }
        })
    }
    
    func outletListNearBy(coordinates: (lat: Double, lon: Double), completion: @escaping OutletListResultType) {
        self.outletListFromProvider(for: coordinates, completion: { result in
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(.other(error.errorDescription)))
            }
        })
    }
    
    
    private func searchOutletListFromProvider(with text: String, for coords: (lat: Double, lon: Double), completion: @escaping ForsqareOutletList) {
        
        self.foursquareProvider.searchOutlet(with: text, userCoordinate: coords) { (result) in
            switch result {
            case let .success(outlets):
                completion(ResultType.success(outlets))
            case let .failure(error):
                completion(ResultType.failure(error))
            }
        }
    }
    
    private func outletListFromProvider(for coords: (lat: Double, lon: Double),
                                        completion: @escaping (ResultType<[OutletEntity], FoursqareProviderError>) -> Void) {
        
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
