//
//  Product+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 5/2/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var scanned: Bool
    @NSManaged public var brand: String?
    @NSManaged public var weightPerPiece: String?
    @NSManaged public var toCategory: Category?
    @NSManaged public var toShopList: NSSet?
    @NSManaged public var toStatistic: NSSet?
    @NSManaged public var toUom: Uom?

}

// MARK: Generated accessors for toShopList
extension Product {

    @objc(addToShopListObject:)
    @NSManaged public func addToToShopList(_ value: ShopList)

    @objc(removeToShopListObject:)
    @NSManaged public func removeFromToShopList(_ value: ShopList)

    @objc(addToShopList:)
    @NSManaged public func addToToShopList(_ values: NSSet)

    @objc(removeToShopList:)
    @NSManaged public func removeFromToShopList(_ values: NSSet)

}

// MARK: Generated accessors for toStatistic
extension Product {

    @objc(addToStatisticObject:)
    @NSManaged public func addToToStatistic(_ value: Statistic)

    @objc(removeToStatisticObject:)
    @NSManaged public func removeFromToStatistic(_ value: Statistic)

    @objc(addToStatistic:)
    @NSManaged public func addToToStatistic(_ values: NSSet)

    @objc(removeToStatistic:)
    @NSManaged public func removeFromToStatistic(_ values: NSSet)

}
