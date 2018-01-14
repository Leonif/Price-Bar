//
//  PriceHandling.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataService {
    
    func printPriceStatistics() {
        do {
            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
            statRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let stat = try context.fetch(statRequest)
            
            for st in stat {
                print(st.date!, st.toProduct!.name!, st.price, st.outlet_id!)
            }
            
        } catch  {
            print("price is not got from database")
        }
        
        
        
    }
    
    func getPrice(for barcode: String, and outletId: String) -> Double  {
        do {
            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
            statRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toProduct.id", barcode, "outlet_id", outletId])
            statRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            let stat = try context.fetch(statRequest)
            
            if let priceExist = stat.first {
                return priceExist.price
            }
            
        } catch  {
            print("price is not got from database")
        }
        
        return 0
        
    }
    
    func getMinPrice(for barcode: String, and outletId: String) -> Double  {
        do {
            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
            statRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toProduct.id", barcode, "outlet_id", outletId])
            statRequest.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]
            let stat = try context.fetch(statRequest)
            
            if let priceExist = stat.first {
                
                return priceExist.price
            }
            
        } catch  {
            print("price is not got from database")
        }
        
        return 0
        
    }
    
    
}
