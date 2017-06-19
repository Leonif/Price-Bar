//
//  Statistic+CoreDataProperties.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/19/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData


extension Statistic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistic> {
        return NSFetchRequest<Statistic>(entityName: "Statistic")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var outlet_id: String?
    @NSManaged public var price: Double
    @NSManaged public var toProduct: Product?

}
