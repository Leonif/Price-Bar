//
//  UomFactory.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import Firebase

class UomFactory {
    
    class func mapper(from fbModel: FBUomModel) -> CDUomModel {
        
        return CDUomModel(id: fbModel.id, name: fbModel.name, iterator: fbModel.iterator)
        
        
    }
    
    class func transform(from fbModelList: [FBUomModel]) -> [CDUomModel] {
        
        var cdModelList: [CDUomModel] = []
        
        for uom in fbModelList {
            cdModelList.append(mapper(from: uom))
        }
        
        return cdModelList
    }
    
    
    func uomMapper(from snapUom: DataSnapshot) -> FBUomModel {
        guard let id = Int32(snapUom.key),
            let uomDict = snapUom.value as? Dictionary<String,Any>,
            let uomName = uomDict["name"] as? String,
            let uomIterator = uomDict["iterator"] as? Double else {
                fatalError("Category os not parsed")
        }
        
        return FBUomModel(id: id, name: uomName, iterator: uomIterator)
        
    }
    
    
    
}
