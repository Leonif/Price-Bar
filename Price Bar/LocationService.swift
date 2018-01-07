//
//  LocationService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/7/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import MapKit




enum LocationServiceError: Error {
    case notAuthorizedAccess(String)
    case servicesIsNotAvailable(String)
    case other(String)
    
    var errorDescription: String {
        switch self {
        case let .notAuthorizedAccess(description),
             let .servicesIsNotAvailable(description),
             let .other(description):
            return description
        }
    }
}



class LocationService {
    let locationManager = CLLocationManager()
    var input: CLLocationManagerDelegate?
    
    init(input: CLLocationManagerDelegate) {
        self.input = input
    }
    
    func startReceivingLocationChanges() -> ResultType<Bool, LocationServiceError> {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            locationManager.requestWhenInUseAuthorization()
            return ResultType.failure(.notAuthorizedAccess("User has not authorized access to location information."))
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return ResultType.failure(.servicesIsNotAvailable("Location services is not available."))
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = input
        locationManager.startUpdatingLocation()
        
        return ResultType.success(true)
    }
    
    
}
