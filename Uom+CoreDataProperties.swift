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
    @NSManaged public var toProduct: NSSet?

}

// MARK: Generated accessors for toProduct
extension Uom {

    @objc(addToProductObject:)
    @NSManaged public func addToToProduct(_ value: Product)

    @objc(removeToProductObject:)
    @NSManaged public func removeFromToProduct(_ value: Product)

    @objc(addToProduct:)
    @NSManaged public func addToToProduct(_ values: NSSet)

    @objc(removeToProduct:)
    @NSManaged public func removeFromToProduct(_ values: NSSet)

}
