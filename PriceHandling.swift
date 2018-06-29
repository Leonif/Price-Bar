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

//    func getPrice(for barcode: String, and outletId: String) -> Double {
//        do {
//            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
//            statRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toProduct.id", barcode, "outletId", outletId])
//            statRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//            let stat = try context.fetch(statRequest)
//
//            if let priceExist = stat.first {
//                return priceExist.price
//            }
//        } catch {
//            fatalError("price is not got from database")
//        }
//        return 0
//
//    }

//    func getMinPrice(for barcode: String, and outletId: String) -> Double {
//        do {
//            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
//            statRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["toProduct.id", barcode, "outletId", outletId])
//            statRequest.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]
//            let stat = try context.fetch(statRequest)
//
//            if let priceExist = stat.first {
//
//                return priceExist.price
//            }
//
//        } catch {
//            fatalError("price is not got from database")
//        }
//
//        return 0
//    }

//    func getPricesStatisticByOutlet(for barcode: String) -> [CDStatisticModel] {
//       
//        var statistics: [CDStatisticModel] = []
//        
//        do {
//            let statRequest = NSFetchRequest<Statistic>(entityName: "Statistic")
//            statRequest.predicate = NSPredicate(format: "%K == %@", argumentArray:["toProduct.id", barcode])
//            statRequest.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]
//            let stat = try context.fetch(statRequest)
//            
//            stat.forEach { s in
//                
//                let model = CDStatisticModel(productId: barcode,
//                                             price: s.price,
//                                             outletId: s.outletId!,
//                                             date: s.date! as Date)
//                
//                
//                statistics.append(model)
//            }
//            
//        } catch {
//            fatalError("price is not got from database")
//        }
//        return statistics
//    }
}
