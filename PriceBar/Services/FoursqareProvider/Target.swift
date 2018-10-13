//
//  Target.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import MapKit

enum Target {
    static let baseUrl = "https://api.foursquare.com/v2/venues/"
    static let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
    static let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
    static let credential = "&client_id=\(clientId)&client_secret=\(clientSecret)"
    static let dateString = Date().getString(format: "yyyyMMdd")
    
    
    case byCategory([String], (lat: Double, lon: Double))
    case getOutleyById(String)
    case searhOutlet(String, (lat: Double, lon: Double))
    
    
}


// MARK: URL
extension Target {
    
    var options: String {
        return "client_id=\(Target.clientId)&client_secret=\(Target.clientSecret)&v=\(Target.dateString)"
    }
    
    
    var url: String {
        var url = ""
        switch self {
        case let .byCategory(categoriesArray, location):
            let lat = location.lat
            let lng = location.lon
            let categories = categoriesArray.joined(separator: ",")
            let locationSearch = "ll=\(lat),\(lng)&radius=\(1000)"
            let intent = "intent=checkin"
            
            url = "\(Target.baseUrl)search?categoryId=\(categories)&\(locationSearch)&\(intent)&\(options)"
            
        case let .getOutleyById(outletId):
            url = "\(Target.baseUrl)\(outletId)?\(Target.credential)&v=\(Target.dateString)"
        case let .searhOutlet(text, location):
            let lat = location.lat
            let lng = location.lon
            
            let locationSearch = "ll=\(lat),\(lng)&radius=\(1000)"
            
            url = "\(Target.baseUrl)search?\(locationSearch)&query=\(text)&\(options)"
        }
        return url
    }
}


