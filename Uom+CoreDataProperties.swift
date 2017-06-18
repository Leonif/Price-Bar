//
//  Uom+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/18/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData


extension Uom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Uom> {
        return NSFetchRequest<Uom>(entityName: "Uom")
    }

    @NSManaged public var uom: String?
    @NSManaged public var iterator: Double
    @NSManaged public var toProduct: Products?

}
