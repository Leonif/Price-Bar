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
    class func parseUom(from snapshot: DataSnapshot) -> FBUomModel {
        guard let id = Int32(snapshot.key),
            let uomDict = snapshot.value as? Dictionary<String, Any>,
            let uomName = uomDict["name"] as? String,
            let uomIterator = uomDict["iterator"] as? Double else {
                fatalError("Category os not parsed")
        }
        var fbUom = FBUomModel(id: id, name: uomName,
                               iterator: uomIterator, koefficients: [], suffixes: [])
        if let koeffs = snapshot.childSnapshot(forPath: "parameters").childSnapshot(forPath: "koefficients").children.allObjects as? [DataSnapshot] {
            for k in koeffs {
                guard let koeefValue = k.value as? Double else {
                    fatalError("Uom koefficinets parse error")
                }
                fbUom.koefficients.append(koeefValue)
            }
        }
        if let suffixess = snapshot.childSnapshot(forPath: "parameters").childSnapshot(forPath: "suffixes").children.allObjects as? [DataSnapshot] {
            
            for s in suffixess {
                guard let suffValue = s.value as? String else {
                    fatalError("Uom suffixes parse error")
                }
                fbUom.suffixes.append(suffValue)
            }
        }
        return fbUom
    }
    
    class func parseUoms(from fbModelList: [DataSnapshot]) -> [FBUomModel] {
        return fbModelList.map { snapUom in
            parseUom(from: snapUom)
        }
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
    
    class func transform(from snapGoods: [String: Any]) -> [FBProductModel] {
        //var fbModels: [FBProductModel] = []
        
        return snapGoods.map { snap in
           parse(snap)
        }
        
        //return fbModels
    }
    
    
    
}
