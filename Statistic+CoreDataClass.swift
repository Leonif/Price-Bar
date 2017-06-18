//
//  Statistic+CoreDataClass.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/18/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData

@objc(Statistic)
public class Statistic: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = NSDate()
    }
}
