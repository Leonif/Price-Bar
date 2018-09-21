//
//  ShoplistDataSource.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

enum ShoplistDataSource {
    case products(title: String, elements: [ShoplistViewItem])
    case notes(title: String, elements: [Int])
    
    func getItem<T>(for index: Int) -> T {
        switch self {
        case let .products(data): return data.elements[index] as! T
        case let .notes(data):return data.elements[index] as! T
        }
    }
    
    func getHeaderTitle() -> String {
        switch self {
        case let .products(data): return data.title
        case let .notes(data):    return data.title
        }
    }
    
    func getElementCount() -> Int {
        switch self {
        case let .products(data): return data.elements.count
        case let .notes(data): return data.elements.count
        }
    }
    
    mutating func remove(index: Int) {
        switch self {
        case let .products(data):
            var mute = data.elements
            mute.remove(at: index)
            self = .products(title: data.title, elements: mute)
        case let .notes(data):
            var mute = data.elements
            mute.remove(at: index)
            self = .notes(title: data.title, elements: mute)
        }
    }
}
