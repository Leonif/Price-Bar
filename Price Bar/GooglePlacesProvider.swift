//
//  GooglePlacesProvider.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import GooglePlaces


class GooglePlacesProvider {
    var placesClient: GMSPlacesClient!

    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    func getOutlet(for outletId: String, callback: @escaping (GMSPlace) -> Void) {
    
        self.placesClient.lookUpPlaceID(outletId) { (gmsPlace, error) in
            if let error = error {
                fatalError("Pick Place error: \(error.localizedDescription)")
            }
            
            callback(gmsPlace!)
            
        }
    
    
    }
    
    
    
    func getOutlet(with searchText: String, callback: @escaping ([GMSAutocompletePrediction]) -> Void) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "UA"
        
        
        self.placesClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (result, error) in
            guard let foundList = result else { fatalError() }
            
            callback(foundList)
        }
    }
    
    func getNearestOutletList(callback: @escaping ([GMSPlaceLikelihood]) -> Void) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                fatalError("Pick Place error: \(error.localizedDescription)")
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                placeLikelihoodList.likelihoods.forEach {
                    print($0.place.types)
                }
                let stores = placeLikelihoodList.likelihoods.filter {
                    $0.place.types.contains("store")
                }
                callback(stores)
                
            }
        })
    }
    
    func getNearestOutlet(callback: @escaping (GMSPlaceLikelihood) -> Void) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                fatalError("Pick Place error: \(error.localizedDescription)")
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                placeLikelihoodList.likelihoods.forEach {
                    print($0.place.types)
                }
                let stores = placeLikelihoodList.likelihoods.filter {
                    $0.place.types.contains("store")
                }
                callback(stores.first!)
                
            }
        })
    }
    
    
    
    
}
