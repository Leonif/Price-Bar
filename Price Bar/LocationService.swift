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

class LocationService: NSObject {
    let locationManager = CLLocationManager()
    var coordinatesResult: ((ResultType<CLLocationCoordinate2D, LocationServiceError>) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    private func startReceivingLocationChanges() {
        if !CLLocationManager.locationServicesEnabled() {
            self.coordinatesResult?(ResultType.failure(.servicesIsNotAvailable("Location services is not available.")))
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.startUpdatingLocation()
    }

    private func stopLocationUpdating() {
        locationManager.stopUpdatingLocation()
    }

    public func getCoords(completion: @escaping (ResultType<CLLocationCoordinate2D, LocationServiceError>)->Void) {
        self.coordinatesResult = completion
        let status: CLAuthorizationStatus = getAuthStatus()
        handle(status)
    }

    private func getAuthStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    private func handle(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            startReceivingLocationChanges()
        case .denied:
            self.coordinatesResult?(ResultType
                .failure(
                    .notAuthorizedAccess(R.string.localizable.no_gps_access())))
        default:
            print(status)
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handle(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        stopLocationUpdating()
        if let  userCoord = locations.last?.coordinate {
            coordinatesResult?(ResultType.success(userCoord))
        } else {
            self.coordinatesResult?(ResultType.failure(.servicesIsNotAvailable("Coorddinate is not gotton")))
        }
    }
}
