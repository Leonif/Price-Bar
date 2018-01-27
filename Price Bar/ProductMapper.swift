//
//  ProductMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation



class ProductMapper {
    class func mapper(from dpModel: DPProductModel, for outletId: String) -> ItemListModelView {
        let dataProvider = DataProvider()
        let price = dataProvider.getPrice(for: dpModel.id, and: outletId)
        let minPrice = dataProvider.getMinPrice(for: dpModel.id, and: outletId)
        
        return ItemListModelView(id: dpModel.id,
                             product: dpModel.name,
                             currentPrice: price,
                             minPrice: minPrice)
    }
    
    class func transform(from dpModels: [DPProductModel], for outletId: String) -> [ItemListModelView]? {
        var itemModels: [ItemListModelView] = []
    
        for dpModel in dpModels {
            itemModels.append(mapper(from: dpModel, for: outletId))
        }
        
        return itemModels
    }
    
    class func mapper(from newBarcode: String) -> ProductCardModelView {
        let dataProvider = DataProvider()
        
        guard let category = dataProvider.defaultCategory else {
            fatalError("default category is not found")
        }
        guard let uom = dataProvider.defaultUom else {
            fatalError("default uom is not found")
        }
        
        return ProductCardModelView(productId: newBarcode,
                                    productName: "",
                                    categoryId: category.id,
                                    categoryName: category.name,
                                    productPrice: 0.0,
                                    uomId: uom.id,
                                    uomName: uom.name)
    }
    
    class func mapper(for newItemName: String) -> ProductCardModelView {
        let dataProvider = DataProvider()
        
        guard let category = dataProvider.defaultCategory else {
            fatalError("default category is not found")
        }
        guard let uom = dataProvider.defaultUom else {
            fatalError("default uom is not found")
        }
        
        let newid = NSUUID().uuidString
        return ProductCardModelView(productId: newid,
                                    productName: newItemName.capitalized,
                                    categoryId: category.id,
                                    categoryName: category.name,
                                    productPrice: 0.0,
                                    uomId: uom.id,
                                    uomName: uom.name)
    }
    
    
    class func parse(_ snapGood: (key: String, value: Any)) -> FBProductModel {
        guard let goodDict = snapGood.value as? Dictionary<String, Any> else {
            fatalError("Product is not parsed")
        }
        let id = snapGood.key
        guard let name = goodDict["name"] as? String else {
            fatalError("Product is not parsed")
        }
        
        let defaultCategoryid: Int32 = 1
        
        var catId = goodDict["category_id"] as? Int32
        catId = catId == nil ? defaultCategoryid : catId
        
        let defaultUomid: Int32 = 1
        
        var uomId = goodDict["uom_id"] as? Int32
        uomId = uomId == nil ? defaultUomid : uomId
        
        return FBProductModel(id: id,
                              name: name,
                              categoryId: catId!,
                              uomId: uomId!)
    }
    
    class func transform(from snapGoods: [String: Any]) -> [FBProductModel]  {
        var fbModels: [FBProductModel] = []
        
        for snap in snapGoods {
            fbModels.append(parse(snap))
        }
        
        return fbModels
    }
}
