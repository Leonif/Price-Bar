//
//  OutletModel.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreLocation


class OutletListModel {
    
    
    var outlets = [Outlet]()
    var delegate: Exchange?
    
    var count: Int {
        return outlets.count
    }
    
    func getOutlet(index: IndexPath) -> Outlet {
        
        return outlets[index.row]
    }
    func getNearestOutlet(coordinate:CLLocationCoordinate2D, completion: @escaping (Bool)->()) {
        self.loadOultets(userCoordinate: coordinate, completed: {
            if let outlet = self.outlets.first {
                self.delegate?.objectExchange(object: outlet)
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func loadOultets(userCoordinate:CLLocationCoordinate2D, completed: @escaping ()->()) {
        let baseUrl = "https://api.foursquare.com/v2/venues/"
        let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
        let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
        let foodAndDrinkShop = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
        let convenienceStore = "4d954b0ea243a5684a65b473"
        let lat = userCoordinate.latitude
        let lng = userCoordinate.longitude
        
        let requestURL = baseUrl + "search?categoryId=\(foodAndDrinkShop),\(convenienceStore)&ll=\(lat),\(lng)&radius=1000&intent=browse&client_id=\(clientId)&client_secret=\(clientSecret)&v=20170614"
        
        let url = URL(string: requestURL)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "")
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
                                            self.outlets.append(Outlet(id, name, add, dist))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.outlets = self.outlets.sorted(by: { $0.distance < $1.distance })
                    DispatchQueue.main.async() {//go into UI
                        completed()
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            }.resume()
    }
}

class Outlet {
    var id = ""
    var name = ""
    var address = ""
    var distance = 0.0
    
    init(_ id: String, _ name: String, _ address: String, _ distance: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.distance = distance
    }
    
    
}
