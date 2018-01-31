//
//  CoreDataParsers.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/31/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class CoreDataParsers {
    class func parse(from uom: Uom) -> CDUomModel? {
        guard let uomName = uom.uom else {
            return nil
        }
        guard
            let uomKoeffs = uom.koefficients,
            let uomSuffs = uom.suffixes else {
                return nil
        }
        
        let uomUterator = uom.iterator
        return CDUomModel(id: uom.id,
                          name: uomName,
                          iterator: uomUterator,
                          koefficients: uomKoeffs,
                          suffixes: uomSuffs)
    }
    
    class func parse(from uom: Uom) -> UomModelView {
        guard let uomName = uom.uom else {
            fatalError("uomName error")
        }
        return UomModelView(id: uom.id, name:  uomName)
    }
    
    class func parse(from uoms: [Uom]) -> [UomModelView] {
        return uoms.map { uom in
            parse(from: uom)
        }
    }
    
    
}
