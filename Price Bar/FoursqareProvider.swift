//
//  FoursqareService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreLocation


typealias ForsqareResult<T> = (ResultType<T, FoursqareProviderError>)->Void
typealias DictionaryType = [String: Any]


typealias ForsqareOutletList = (ResultType<[FQOutletModel], FoursqareProviderError>)->Void
typealias ForsqareSungleOutlet = (ResultType<FQOutletModel, FoursqareProviderError>)->Void



enum FoursqareProviderError: Error {
    case foursqareDoesntResponce(String)

    case wrongURL(String)
    case parseError(String)
    case noOutlets(String)

    case other(String)

    var errorDescription: String {
        switch self {
        case let .foursqareDoesntResponce(description),
             let .wrongURL(description),
             let .parseError(description),
             let .noOutlets(description),
             let .other(description):
            return description
        }
    }
}

enum Target {
    
    static let baseUrl = "https://api.foursquare.com/v2/venues/"
    static let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
    static let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
    static let credeantial = "&client_id=\(clientId)&client_secret=\(clientSecret)"
    static let dateString = Date().getString(format: "yyyyMMdd")
    
    
    
    
    case byCategory(String, String, CLLocationCoordinate2D)
    case getOutleyById(String)
    
    var url: String {
        switch self {
        case let .byCategory(categories1, categories2, location):
            let lat = location.latitude
            let lng = location.longitude
            
            let categorySearch = "search?categoryId=\(categories1),\(categories2)"
            let locationSearch = "ll=\(lat),\(lng)&radius=\(1000)"
            
            return "\(Target.baseUrl)\(categorySearch)&\(locationSearch)&intent=browse&client_id=\(Target.clientId)&client_secret=\(Target.clientSecret)&v=\(Target.dateString)"
        
        case let .getOutleyById(outletId):
            return "\(Target.baseUrl)\(outletId)?\(Target.credeantial)&v=\(Target.dateString)"
        }
    }
    
}




class FoursqareProvider {
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
    let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
    

    
    
    
    private func request<T>(url: URL,
                            completed: @escaping ForsqareResult<T>,
                            parseFunction: @escaping (DictionaryType, ForsqareResult<T>)->()) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completed(ResultType.failure(.foursqareDoesntResponce(error.localizedDescription)))
                return
            }
            do {
                guard
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let resp = parsedData["response"] as? DictionaryType
                    else {
                        self.handleParseError(completed: completed)
                        return
                }
                parseFunction(resp, completed)
            } catch let error as NSError {
                completed(ResultType.failure(.other(error.localizedDescription)))
            }}.resume()
    }
    
    func getOutlet(with id: String, completion: @escaping ForsqareSungleOutlet) {
        let url = URL(string: Target.getOutleyById(id).url)!
        self.request(url: url, completed: completion) { (dict, result) in
            self.parseVenue(from: dict, completion: completion)
        }
    }
    
    private func parseVenue(from resp: DictionaryType, completion: @escaping ForsqareSungleOutlet) {
        guard let venue = resp["venue"] as? [String: Any] else {
            self.handleParseError(completed: completion)
            return
        }
        
        guard let outletModel = outletMapper(from: venue) else {
            self.handleParseError(completed: completion)
            return
        }
        completion(ResultType.success(outletModel))
    }
    
    
    func loadOultets(userCoordinate: CLLocationCoordinate2D, completion: @escaping ForsqareOutletList) {
        
        let foodAndDrinkShop = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
        let convenienceStore = "4d954b0ea243a5684a65b473"
        
        let url = URL(string: Target.byCategory(foodAndDrinkShop, convenienceStore, userCoordinate).url)!
        self.request(url: url, completed: completion) { (dict, result) in
            self.parseVenues(from: dict, completion: completion)
        }
    
    }
    
    
    
    
    
    
//    func loadOultets(userCoordinate: CLLocationCoordinate2D, completed: @escaping forsqareOutletList) {
//
//        self.loadOultets2(userCoordinate: userCoordinate, completed: completed, parseFunction: parseVenues)
//
//    }

    
//    private func loadOultets2(userCoordinate: CLLocationCoordinate2D, completed: @escaping forsqareOutletList, parseFunction: parseOutletListBlock) {
//        let lat = userCoordinate.latitude
//        let lng = userCoordinate.longitude
//        let dateString = Date().getString(format: "yyyyMMdd")
//
//        let categorySearch = "search?categoryId=\(foodAndDrinkShop),\(convenienceStore)"
//        let locationSearch = "ll=\(lat),\(lng)&radius=\(1000)"
//        let requestURL = "\(baseUrl)\(categorySearch)&\(locationSearch)&intent=browse&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateString)"
//        guard let url = URL(string: requestURL) else {
//            completed(ResultType.failure(.wrongURL("Неправильный URL 😢")))
//            return
//        }
//        self.request(url: url, completed: completed, parseFunction: parseFunction)
//    }
    
    
    
   
    
    
    
    
    private func parseVenues(from resp: [String: Any], completion: @escaping ForsqareOutletList) {

        var outlets: [FQOutletModel] = []

        guard let venues = resp["venues"] as? [[String: Any]] else {
            self.handleParseError(completed: completion)
            return
        }
        for v in venues {
            if let fqModel = self.outletMapperWithDistance(from: v) {
                outlets.append(fqModel)
            }
        }
        guard !outlets.isEmpty else {
            completion(ResultType.failure(.noOutlets("Не найдены вокруг вас магазины 😢")))
            return
        }
        outlets = outlets.sorted(by: { $0.distance < $1.distance })

        completion(ResultType.success(outlets))

    }
    
    
    
    
    
    
    private func outletMapperWithDistance(from venue: DictionaryType) -> FQOutletModel? {
        var outletWithDistance: FQOutletModel
        
        guard let outletModel = self.outletMapper(from: venue) else {
            return nil
        }
        outletWithDistance = outletModel
        guard
            let loc = venue["location"] as? [String: Any],
            let dist = loc["distance"] as? Double else {
                return nil
        }
        outletWithDistance.distance = dist
        
        return outletWithDistance
    }
    
    
    private func outletMapper(from venue: [String: Any]) -> FQOutletModel? {
        guard
            let id = venue["id"] as? String,
            let name = venue["name"] as? String,
            let loc = venue["location"] as? [String: Any],
            let add = loc["address"] as? String else {
                return nil
        }
        return FQOutletModel(id: id,
                             name: name,
                             address: add,
                             distance: 0)
    }
    
    
    
    private func handleParseError<T>(completed: @escaping ForsqareResult<T>) {
        completed(ResultType.failure(.parseError("Что-то пошло не так")))
    }

}
