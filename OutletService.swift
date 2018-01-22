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
    func list(result: ResultType<[Outlet], OutletServiceError>)
}

protocol NearestOutletDelegate {
    func nearest(result: ResultType<Outlet, OutletServiceError>)
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
    var nearestOutletDelegate: NearestOutletDelegate?
    var outletListDelegate: OutletListDelegate?
    var singleOutletCompletion: ((ResultType<Outlet, OutletServiceError>) -> Void)?
    var outletListCompletion: ((ResultType<[Outlet], OutletServiceError>) -> Void)?
    
    func nearestOutlet(completion: @escaping (ResultType<Outlet, OutletServiceError>)->())  {
        singleOutletCompletion = completion
        locationService = LocationService(input: self)
        let result = locationService.startReceivingLocationChanges()
        switch result {
        case let .failure(error):
            print(error)
            // User has not authorized access to location information.
        default:
            print("ok")
        }
    }
    
    
    func outletList(completion: @escaping (ResultType<[Outlet], OutletServiceError>)->())  {
        outletListCompletion = completion
        locationService = LocationService(input: self)
        let result = locationService.startReceivingLocationChanges()
        switch result {
        case let .failure(error):
            print(error)
        default:
            print("ok")
        }
    }
    
    
    func startLookingForOutletList(outletListDelegate: OutletListDelegate) {
        self.outletListDelegate = outletListDelegate
        locationService = LocationService(input: self)
        _ = locationService?.startReceivingLocationChanges()
    }
    
    
    func loadOultets(userCoordinate:CLLocationCoordinate2D, completed: @escaping (ResultType<[Outlet], OutletServiceError>)->()) {
        let baseUrl = "https://api.foursquare.com/v2/venues/"
        let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
        let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
        let foodAndDrinkShop = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
        let convenienceStore = "4d954b0ea243a5684a65b473"
        let lat = userCoordinate.latitude
        let lng = userCoordinate.longitude
        
        let dateString = Date().getString(format: "yyyyMMdd")
        var outlets = [Outlet]()
        
        let requestURL = baseUrl + "search?categoryId=\(foodAndDrinkShop),\(convenienceStore)&ll=\(lat),\(lng)&radius=1000&intent=browse&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateString)"
        
        guard let url = URL(string: requestURL) else {
            completed(ResultType.failure(.wrongURL("Неправильный URL 😢")))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completed(ResultType.failure(.foursqareDoesntResponce(error.localizedDescription)))
            } else {
                do {
                    if let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]  {
                        if let resp = parsedData["response"] as? [String: Any]  {
                            print(resp)
                            if let venues = resp["venues"] as? [[String:Any]] {
                                for v in venues {
                                    if let id = v["id"] as? String, let name = v["name"] as? String, let loc = v["location"] as? [String:Any]  {
                                        if let add = loc["address"] as? String, let dist = loc["distance"] as? Double {
                                            print(id, name, add, dist)
                                            outlets.append(Outlet(id, name, add, dist))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    outlets = outlets.sorted(by: { $0.distance < $1.distance })
                    //DispatchQueue.main.async() {//go into UI
                    completed(ResultType.success(outlets))
                    //}
                } catch let error as NSError {
                    completed(ResultType.failure(.other(error.localizedDescription)))
                }
            }
            }.resume()
    }
}


extension OutletService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        switch status {
        case .authorizedWhenInUse:
            _ = locationService?.startReceivingLocationChanges()
        case .denied:
            self.singleOutletCompletion?(ResultType.failure(.outletNotFound("Мы не можем найти магазины возле вас. Вы запретили следить за вашей позицией. Включите в настройках, чтобы использовать программу 😢")))
        default:
            print(status)
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let  userCoord = locations.last?.coordinate else {
            fatalError("Coorddinate is not gotton")
        }
        self.loadOultets(userCoordinate: userCoord, completed: { result in
            self.locationService?.stopLocationUpdating()
            switch result {
            case let .success(outlets):
                if let comletion = self.singleOutletCompletion {
                    guard let outlet = outlets.first else {
                        fatalError("Outlet is not found")
                    }
                    comletion(ResultType.success(outlet))
                    
                } else if let comletion = self.outletListCompletion {
                    comletion(ResultType.success(outlets))
                } else {
                    fatalError("Completion is not passed")
                }
            case let .failure(error):
                fatalError(error.errorDescription)
                
            }
        })
    }
}


