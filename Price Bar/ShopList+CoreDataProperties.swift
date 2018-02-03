//
//  ShopList+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 2/3/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension ShopList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShopList> {
        return NSFetchRequest<ShopList>(entityName: "ShopList")
    }

    @NSManaged public var checked: Bool
    @NSManaged public var outletId: String?
    @NSManaged public var quantity: Double
    @NSManaged public var toProduct: Product?

}
