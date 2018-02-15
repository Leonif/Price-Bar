//
//  FoursqareService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreLocation


typealias forsqareResponce = (ResultType<[FQOutletModel], FoursqareProviderError>)->Void

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

class FoursqareProvider {
    let baseUrl = "https://api.foursquare.com/v2/venues/"
    let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
    let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
    let foodAndDrinkShop = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
    let convenienceStore = "4d954b0ea243a5684a65b473"

    func loadOultets(userCoordinate: CLLocationCoordinate2D, completed: @escaping forsqareResponce) {
        let lat = userCoordinate.latitude
        let lng = userCoordinate.longitude
        let dateString = Date().getString(format: "yyyyMMdd")
        
        let categorySearch = "search?categoryId=\(foodAndDrinkShop),\(convenienceStore)"
        let locationSearch = "ll=\(lat),\(lng)&radius=\(1000)"
        let requestURL = "\(baseUrl)\(categorySearch)&\(locationSearch)&intent=browse&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(dateString)"
        guard let url = URL(string: requestURL) else {
            completed(ResultType.failure(.wrongURL("Неправильный URL 😢")))
            return
        }
        parse(url: url, completed: completed)
    }
    
    private func parse(url: URL, completed: @escaping forsqareResponce) {
        var outlets: [FQOutletModel] = []
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completed(ResultType.failure(.foursqareDoesntResponce(error.localizedDescription)))
                return
            }
            do {
                guard
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let resp = parsedData["response"] as? [String: Any],
                    let venues = resp["venues"] as? [[String: Any]]
                    else {
                        self.handleParseError(completed: completed)
                        return
                }
                for v in venues {
                    if let fqModel = self.mapper(from: v) {
                        outlets.append(fqModel)
                    }
                }
                guard !outlets.isEmpty else {
                    completed(ResultType.failure(.noOutlets("Не найдены магазины 😢")))
                    return
                }
                outlets = outlets.sorted(by: { $0.distance < $1.distance })
                completed(ResultType.success(outlets))
            } catch let error as NSError {
                completed(ResultType.failure(.other(error.localizedDescription)))
            }
            }.resume()
    }
    
    private func mapper(from venue: [String: Any]) -> FQOutletModel? {
        
        guard
            let id = venue["id"] as? String,
            let name = venue["name"] as? String,
            let loc = venue["location"] as? [String: Any],
            let add = loc["address"] as? String,
            let dist = loc["distance"] as? Double else {
                return nil
        }
        return FQOutletModel(id: id,
                      name: name,
                      address: add,
                      distance: dist)
    }
    
    private func handleParseError(completed: forsqareResponce) {
        completed(ResultType.failure(.parseError("Что-то пошло не так")))
    }

}
