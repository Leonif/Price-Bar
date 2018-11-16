//
//  ShopListMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ShopListMapper {

    func transform(input: [ShopListViewItem], categoryList: [String]) -> [ShopListDataSource] {
        var output: [ShopListDataSource] = []
        for category in categoryList {
            let items = input.filter { $0.productCategory == category }

            if !items.isEmpty {
                output.append(.products(title: category, elements: items))
            }
        }
        return output
    }
}
