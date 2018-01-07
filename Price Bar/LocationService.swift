//
//  LocationService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/7/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import MapKit

class LocationService {
    let locationManager = CLLocationManager()
    var input: CLLocationManagerDelegate?
    
    init(input: CLLocationManagerDelegate) {
        
        self.input = input
    }
    
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            locationManager.requestWhenInUseAuthorization()
            //return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = input
        locationManager.startUpdatingLocation()
    }
    
    
}
