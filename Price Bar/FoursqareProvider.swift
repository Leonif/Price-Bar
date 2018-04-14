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
typealias ForsqareSingleOutlet = (ResultType<FQOutletModel, FoursqareProviderError>)->Void


class FoursqareProvider {
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
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? DictionaryType
                    else {
                        self.handleParseError(completed: completed)
                        return
                }
                
                parseFunction(parsedData, completed)
            } catch let error as NSError {
                completed(ResultType.failure(.other(error.localizedDescription)))
            }}.resume()
    }
    
    func getOutlet(with id: String, completion: @escaping ForsqareSingleOutlet) {
        let url = URL(string: Target.getOutleyById(id).url)!
        self.request(url: url, completed: completion) { (dict, result) in
            self.parseVenue(from: dict, completion: completion)
        }
    }
    
    func loadOultets(userCoordinate: CLLocationCoordinate2D, completion: @escaping ForsqareOutletList) {
        
        let foodAndDrinkShop = "4bf58dd8d48988d1f9941735"
        let convenienceStore = "4d954b0ea243a5684a65b473"
        
        let url = URL(string: Target.byCategory([foodAndDrinkShop, convenienceStore], userCoordinate).url)!
        self.request(url: url, completed: completion) { (dict, result) in
            self.parseVenues(from: dict, completion: completion)
        }
    }
    
    
    func searchOutlet(with text: String, userCoordinate: CLLocationCoordinate2D, completion: @escaping ForsqareOutletList) {
        
        
        let rr = Target.searhOutlet(text, userCoordinate).url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let url = URL(string: rr)!
        self.request(url: url, completed: completion) { (dict, result) in
            self.parseVenues(from: dict, completion: completion)
        }
        
    }
    
    // MARK: parse function
    private func parseVenue(from dict: DictionaryType, completion: @escaping ForsqareSingleOutlet) {
        
        if let errorDetail = self.metaMapper(dict: dict, completion: completion) {
            self.handleFoursquareError(completed: completion, detail: errorDetail)
            return
        }
        
        guard let resp = dict["response"] as? DictionaryType else {
            self.handleParseError(completed: completion)
            return
        }
        
        
        
        
        guard let venue = resp["venue"] as? DictionaryType else {
            self.handleParseError(completed: completion)
            return
        }
        guard let outletModel = outletMapper(from: venue) else {
            self.handleParseError(completed: completion)
            return
        }
        completion(ResultType.success(outletModel))
    }

    private func parseVenues(from dict: DictionaryType, completion: @escaping ForsqareOutletList) {
        
        if let errorDetail = metaMapper(dict: dict, completion: completion) {
            self.handleFoursquareError(completed: completion, detail: errorDetail)
            return
        }

        guard let resp = dict["response"] as? DictionaryType else {
            self.handleParseError(completed: completion)
            return
        }

        var outlets: [FQOutletModel] = []

        guard let venues = resp["venues"] as? [DictionaryType] else {
            self.handleParseError(completed: completion)
            return
        }
        for v in venues {
            if let fqModel = self.outletMapperWithDistance(from: v) {
                outlets.append(fqModel)
            }
        }
        guard !outlets.isEmpty else {
            completion(ResultType.failure(.noOutlets(R.string.localizable.error_stores_is_not_found_around_you())))
            return
        }
        outlets = outlets.sorted(by: { $0.distance < $1.distance })

        completion(ResultType.success(outlets))

    }
    
    // MARK: - Mappers
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
    
    
    private func outletMapper(from venue: DictionaryType) -> FQOutletModel? {
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
    
    
    private func metaMapper<T>(dict: DictionaryType, completion: @escaping ForsqareResult<T>) -> String? {
        guard let meta = dict["meta"] as? DictionaryType else {
            self.handleParseError(completed: completion)
            return nil
        }
        
        if let errorDetail = meta["errorDetail"] as? String {
            return errorDetail
        }
        return nil
    }
    
    private func handleParseError<T>(completed: @escaping ForsqareResult<T>) {
        completed(ResultType.failure(.parseError(R.string.localizable.error_something_went_wrong())))
    }
    
    private func handleFoursquareError<T>(completed: @escaping ForsqareResult<T>, detail: String) {
        completed(ResultType.failure(.parseError("Foursquare error: \(detail)")))
    }
    

}
