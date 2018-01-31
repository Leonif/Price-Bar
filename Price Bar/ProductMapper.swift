//
//  ProductMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ProductMapper {
    class func mapper(from product: DPProductModel, and outletId: String) -> DPShoplistItemModel {

        let dataProvider = DataProvider()

        guard
            let categoryName = dataProvider.getCategoryName(category: product.categoryId),
            let uom = dataProvider.getUomName(for: product.uomId)
            else {
                fatalError("category or uom name doesnt exist")
        }
        let price = dataProvider.getPrice(for: product.id, and: outletId)

        return DPShoplistItemModel(productId: product.id,
                                               productName: product.name,
                                               categoryId: product.categoryId,
                                               productCategory: categoryName,
                                               productPrice: price,
                                               uomId: product.uomId,
                                               productUom: uom,
                                               quantity: 1.0,
                                               isPerPiece: product.isPerPiece,
                                               checked: false)

    }

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

    class func mapper(from item: DPShoplistItemModel) -> ProductCardModelView {
        return ProductCardModelView(productId: item.productId,
                                    productName: item.productName,
                                    categoryId: item.categoryId,
                                    categoryName: item.productCategory,
                                    productPrice: item.productPrice,
                                    uomId: item.uomId,
                                    uomName: item.productUom)
    }
    
    
    
    
    
    
}
