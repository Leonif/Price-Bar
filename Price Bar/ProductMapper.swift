//
//  ProductMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ProductMapper {
    
    
    
    
    
    class func mapper(from item: FBProductModel) -> DPProductEntity {
        
        return DPProductEntity(id: item.id,
                               name: item.name,
                               brand: item.brand,
                               weightPerPiece: item.weightPerPiece,
                               categoryId: item.categoryId,
                               uomId: item.uomId)
        
    }
    
//    class func mapper(from product: DPProductEntity, price: Double, outletId: String) -> ShoplistItem {
//
//        let repositoriy = Repository()
//
//        guard
//            let categoryName = repositoriy.getCategoryName(category: product.categoryId),
//            let uom = repositoriy.getUom(for: product.uomId)
//            else {
//                fatalError("category or uom name doesnt exist")
//        }
//
//        return ShoplistItem(productId: product.id,
//                                   productName: product.name,
//                                   brand: product.brand,
//                                   weightPerPiece: product.weightPerPiece,
//                                   categoryId: product.categoryId,
//                                   productCategory: categoryName,
//                                   productPrice: price,
//                                   uomId: product.uomId,
//                                   productUom: uom.name,
//                                   quantity: 1.0,
//                                   checked: false,
//                                   parameters: uom.parameters)
//
//    }

    


//    class func mapper(from newBarcode: String) -> ProductCardEntity {
//        let dataProvider = Repository()
//
//        guard let category = dataProvider.defaultCategory else {
//            fatalError("default category is not found")
//        }
//        guard let uom = dataProvider.defaultUom else {
//            fatalError("default uom is not found")
//        }
//
//        return ProductCardEntity(productId: newBarcode,
//                                    productName: "",
//                                    brand: "",
//                                    weightPerPiece: "",
//                                    categoryId: category.id,
//                                    categoryName: category.name,
//                                    productPrice: 0.0,
//                                    uomId: uom.id,
//                                    uomName: uom.name)
//    }

//    class func mapper(for newItemName: String) -> ProductCardEntity {
//        let dataProvider = Repository()
//
//        guard let category = dataProvider.defaultCategory else {
//            fatalError("default category is not found")
//        }
//        guard let uom = dataProvider.defaultUom else {
//            fatalError("default uom is not found")
//        }
//
//        let newid = NSUUID().uuidString
//        return ProductCardEntity(productId: newid,
//                                    productName: newItemName.capitalized,
//                                    brand: "",
//                                    weightPerPiece: "",
//                                    categoryId: category.id,
//                                    categoryName: category.name,
//                                    productPrice: 0.0,
//                                    uomId: uom.id,
//                                    uomName: uom.name)
//    }

//    class func mapper(from item: ShoplistItem) -> ProductCardEntity {
//        return ProductCardEntity(productId: item.productId,
//                                    productName: item.productName,
//                                    brand: item.brand,
//                                    weightPerPiece: item.weightPerPiece,
//                                    categoryId: item.categoryId,
//                                    categoryName: item.productCategory,
//                                    productPrice: item.productPrice,
//                                    uomId: item.uomId,
//                                    uomName: item.productUom)
//    }
    
    
    
    
    
    
}
