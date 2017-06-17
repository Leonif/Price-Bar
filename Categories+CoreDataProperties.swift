//
//  Categories+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/18/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var category: String?
    @NSManaged public var toProduct: NSSet?

}

// MARK: Generated accessors for toProduct
extension Categories {

    @objc(addToProductObject:)
    @NSManaged public func addToToProduct(_ value: Products)

    @objc(removeToProductObject:)
    @NSManaged public func removeFromToProduct(_ value: Products)

    @objc(addToProduct:)
    @NSManaged public func addToToProduct(_ values: NSSet)

    @objc(removeToProduct:)
    @NSManaged public func removeFromToProduct(_ values: NSSet)

}
