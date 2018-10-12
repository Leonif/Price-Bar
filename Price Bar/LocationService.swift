//
//  LocationService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 8/18/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import MapKit

enum LocationServiceError: Error {
    case servicesIsNotAvailable(String)
}

protocol LocationService {
    var onCoordinatesUpdated: (((lat: Double, lon: Double)) -> Void)? { get set }
    var onError: ((LocationServiceError) -> Void)? { get set }
    var onStatusChanged: ((Bool)-> Void)? { get set }
    func getCoords()
}

class LocationServiceImpl: NSObject, CLLocationManagerDelegate, LocationService {
   
    var onCoordinatesUpdated: (((lat: Double, lon: Double)) -> Void)?
    var onError: ((LocationServiceError) -> Void)?
    var onStatusChanged: ((Bool)-> Void)?

    let locationManager = CLLocationManager()
    
    var isLocationSent: Bool = false
    var isStatusSent: Bool = false
    var accessStatus: CLAuthorizationStatus = .denied
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func getCoords() {
        self.accessStatus = CLLocationManager.authorizationStatus()
        switch self.accessStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            self.startReceivingLocationChanges()
        case .denied, .restricted:
            self.isStatusSent = true
            self.isLocationSent = true
            self.locationManager.stopUpdatingLocation()
            self.onError?(LocationServiceError.servicesIsNotAvailable(R.string.localizable.no_gps_access()))
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func startReceivingLocationChanges() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.onStatusChanged?(true)
        default:
            self.onStatusChanged?(false)
        }
        self.isStatusSent = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        self.isLocationSent = true
        if let  userCoord = locations.last?.coordinate {
            self.onCoordinatesUpdated?((userCoord.latitude, userCoord.longitude))
        }
    }
}
