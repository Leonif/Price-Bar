//
//  CategoryMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class CategoryMapper {
    class func transform(input: CategoryEntity) -> CategoryViewItem {
        return CategoryViewItem(id: input.id, name: input.name)
    }

    class func transform(input: CategoryEntity) -> String {
        return input.name
    }
}
