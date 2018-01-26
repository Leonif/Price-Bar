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
    
    class func transform(from dpModels: [DPCategoryModel]) -> [CategoryModelView] {
        
        var modelViews:[CategoryModelView] = []
        
        for dpModel in dpModels {
            modelViews.append(mapper(from: dpModel))
        }
        return modelViews
    }
    
    
    class func mapper(from dpCategory: CDCategoryModel) -> DPCategoryModel {
        return DPCategoryModel(id: dpCategory.id, name: dpCategory.name)
    }
    
    class func transform(from dpModels: [CDCategoryModel]) -> [DPCategoryModel] {
        
        var modelViews:[DPCategoryModel] = []
        
        for dpModel in dpModels {
            modelViews.append(mapper(from: dpModel))
        }
        return modelViews
    }
    
    class func mapper(from category: Category) -> DPCategoryModel {
        
        guard let categoryName = category.category else {
            fatalError("Cant transform from Category to DpCategory")
        }
        
        return DPCategoryModel(id: category.id, name: categoryName)
    }
    
    class func transform(from models: [Category]) -> [DPCategoryModel] {
        
        var modelViews:[DPCategoryModel] = []
        
        for dpModel in models {
            modelViews.append(mapper(from: dpModel))
        }
        return modelViews
    }
    
    
    
    
}
