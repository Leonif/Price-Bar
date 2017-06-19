//
//  ShopList+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/19/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData


extension ShopList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShopList> {
        return NSFetchRequest<ShopList>(entityName: "ShopList")
    }

    @NSManaged public var outlet_id: String?
    @NSManaged public var quantity: Double
    @NSManaged public var toProduct: Product?

}
