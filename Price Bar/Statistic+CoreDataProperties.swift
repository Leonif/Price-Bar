//
//  Statistic+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 5/2/18.
//  Copyright © 2018 LionLife. All rights reserved.
//
//

import Foundation
import CoreData


extension Statistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistic> {
        return NSFetchRequest<Statistic>(entityName: "Statistic")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var outletId: String?
    @NSManaged public var price: Double
    @NSManaged public var toProduct: Product?

}
