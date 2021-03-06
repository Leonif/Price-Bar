//
//  ShoplistDataSource.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ShopListDatasourceManager {

    var dataSource: [ShopListDataSource] = []

    var isEmpty: Bool {
        return dataSource.isEmpty
    }

    func update(dataSource: [ShopListDataSource]) {
        self.dataSource = dataSource
    }

    var numberOfSections: Int {
        return self.dataSource.count
    }

    func appendCategories(with categoryLists: [ShopListDataSource]) {
        self.dataSource = categoryLists
    }

    func getHeaderTitle(for section: Int) -> String {
        return self.dataSource[section].getHeaderTitle()
    }

    func isExists(_ section: Int) -> Bool {
        return self.dataSource.indices.contains(section)
    }

    func getElementsCount(for section: Int) -> Int {
        return self.dataSource[section].getElementCount()
    }

    func getItem<T>(for indexPath: IndexPath) -> T? {
        return self.dataSource[indexPath.section].getItem(for: indexPath.row)
    }

//    func getItem<T>(indexPath: IndexPath) -> T {
//        return dataSource[indexPath.section].getItem(for: indexPath.row)
//    }

    func removeElement(with indexPath: IndexPath) {
        dataSource[indexPath.section].remove(index: indexPath.row)
        self.remove(indexPath.section)
    }

    private func remove(_ section: Int) {
        if dataSource[section].getElementCount() == 0 {
            dataSource.remove(at: section)
        }
    }
}

enum ShopListDataSource {
    case products(title: String, elements: [ShopListViewItem])
    case notes(title: String, elements: [Int])

    func getItem<T>(for index: Int) -> T? {
        switch self {
        case let .products(data):
            return data.elements[index] as? T
        case let .notes(data):
            return data.elements[index] as? T
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
        case let .notes(data):    return data.elements.count
        }
    }

    mutating func remove(index: Int) {
        switch self {
        case let .products(data):
            var mutableElements = data.elements
            mutableElements.remove(at: index)
            self = .products(title: data.title, elements: mutableElements)
        case let .notes(data):
            var mutableElements = data.elements
            mutableElements.remove(at: index)
            self = .notes(title: data.title, elements: mutableElements)
        }
    }
}
