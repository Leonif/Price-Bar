//
//  Category+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 5/2/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var category: String?
    @NSManaged public var id: Int32
    @NSManaged public var toProduct: NSSet?

}

// MARK: Generated accessors for toProduct
extension Category {

    @objc(addToProductObject:)
    @NSManaged public func addToToProduct(_ value: Product)

    @objc(removeToProductObject:)
    @NSManaged public func removeFromToProduct(_ value: Product)

    @objc(addToProduct:)
    @NSManaged public func addToToProduct(_ values: NSSet)

    @objc(removeToProduct:)
    @NSManaged public func removeFromToProduct(_ values: NSSet)

}
