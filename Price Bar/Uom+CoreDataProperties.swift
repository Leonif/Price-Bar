//
//  Uom+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/3/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension Uom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Uom> {
        return NSFetchRequest<Uom>(entityName: "Uom")
    }

    @NSManaged public var id: Int32
    @NSManaged public var uom: String?
    @NSManaged public var parameters: [CDParameter]?
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
