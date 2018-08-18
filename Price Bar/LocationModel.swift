//
//  LocationService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/7/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import MapKit

enum LocationModelError: Error {
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

class LocationModel: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var onCoordinatesUpdated: (((lat: Double, lon: Double)) -> Void)?
    var onError: ((LocationModelError) -> Void)?
    var onStatusChanged: ((Bool)-> Void)?
    
    
    var isLocationSent: Bool = false
    var isStatusSent: Bool = false
    var accessStatus: CLAuthorizationStatus = .denied

    override init() {
        super.init()
        locationManager.delegate = self
    }

    private func startReceivingLocationChanges() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.startUpdatingLocation()
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
            self.onError?(LocationModelError.servicesIsNotAvailable(R.string.localizable.no_gps_access()))
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        guard !self.isLocationSent else { return }
        
        
        
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.onStatusChanged?(true)
        default:
            self.onStatusChanged?(false)
        }
        self.isStatusSent = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard !self.isLocationSent else { return }
        locationManager.stopUpdatingLocation()
        self.isLocationSent = true
        if let  userCoord = locations.last?.coordinate {
            self.onCoordinatesUpdated?((userCoord.latitude, userCoord.longitude))
        } else {
//            self.onError?("Coorddinate is not gotton")
        }
    }
}
