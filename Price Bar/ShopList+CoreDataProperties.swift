//
//  ShopList+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension ShopList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShopList> {
        return NSFetchRequest<ShopList>(entityName: "ShopList")
    }

    @NSManaged public var quantity: Double
    @NSManaged public var productId: String?

}
