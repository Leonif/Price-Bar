//
//  CategoryMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class CategoryMapper {

    class func mapper(from dpCategory: DPCategoryModel) -> CategoryModelView {
        return CategoryModelView(id: dpCategory.id, name: dpCategory.name)
    }

    class func mapper(from dpCategory: CDCategoryModel) -> DPCategoryModel {
        return DPCategoryModel(id: dpCategory.id, name: dpCategory.name)
    }


    
    

}
