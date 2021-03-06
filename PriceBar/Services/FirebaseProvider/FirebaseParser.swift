//
//  FirebaseParser.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
import Foundation
import Firebase

class FirebaseParser {
    class func parse(from snapshot: DataSnapshot) -> CategoryEntity {
        guard let id = Int32(snapshot.key),
            let categoryDict = snapshot.value as? [String: Any],
            let categoryName = categoryDict["name"] as? String else {
                fatalError("Category os not parsed")
        }
        let fbCategory = CategoryEntity(id: id, name: categoryName)
        return fbCategory
    }

    class func parse(from snapshot: DataSnapshot) -> UomEntity {
        guard let id = Int32(snapshot.key),
            let uomDict = snapshot.value as? [String: Any],
            let uomName = uomDict["name"] as? String else {
                fatalError("Category os not parsed")
        }
        var fbUom = UomEntity(id: id,
                               name: uomName,
//                               iterator: 0.0,
                               koefficients: [],
                               suffixes: [],
                               parameters: [])

        if let parameters = snapshot.childSnapshot(forPath: "parameters2").children.allObjects as? [DataSnapshot] {
            for par in parameters {
                guard
                let paramDict = par.value as? [String: Any],
                let maxValue = paramDict["max"] as? Int,
                let step = paramDict["step"] as? Double,
                let suffix = paramDict["suffix"] as? String
//                let viewMultiplicator = paramDict["view_multiplicator"] as? Double
                else {
                    fatalError("Uom koefficients parse error")
                }

                let divider = paramDict["divider"] as? Double ?? 1.0

                fbUom.parameters.append(
                    ParameterEntity(maxValue: maxValue,
                              step: step,
                              suffix: suffix,
//                              viewMultiplicator: viewMultiplicator,
                              divider: divider)
                )
            }
        }
        return fbUom
    }

    class func parse(from snapShots: [DataSnapshot]) -> [UomEntity] {
        return snapShots.map { parse(from: $0) }
    }

    class func parse(from snapGood: (key: String, value: Any)) -> ProductEntity {
        guard let goodDict = snapGood.value as? Dictionary<String, Any> else {
            fatalError("Product is not parsed")
        }
        let productId = snapGood.key
        guard let name = goodDict["name"] as? String else {
            fatalError("Product is not parsed")
        }

        let brand = goodDict["brand"] as? String ?? ""
        let weightPerPiece = goodDict["weight_per_piece"] as? String ?? ""

        let defaultCategoryid: Int32 = 1

        var catId = goodDict["category_id"] as? Int32
        catId = catId == nil ? defaultCategoryid : catId

        let defaultUomid: Int32 = 1

        var uomId = goodDict["uom_id"] as? Int32
        uomId = uomId == nil ? defaultUomid : uomId

        return ProductEntity(productId: productId,
                              name: name,
                              brand: brand,
                              weightPerPiece: weightPerPiece,
                              categoryId: catId!,
                              uomId: uomId!)
    }
}
