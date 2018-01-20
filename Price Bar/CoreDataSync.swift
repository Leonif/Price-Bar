//
//  CoreDataSync.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 1/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData



// MARK: Sync function
extension CoreDataService {
    func syncCategories(_ completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        FirebaseService.data.syncCategories { result in
            switch result {
            case let .success(categories):
                self.importNew(categories)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    public func importNew(_ categories:[ItemCategory])  {
        removeAll(from: "Category")
        categories.forEach { category in
            self.save(new: category)
        }
    }
    func syncUoms(_ completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        FirebaseService.data.syncUoms { result in
            switch result {
            case let .success(uoms):
                self.importNew(uoms)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    
    public func importNew(_ uoms:[UomModel])  {
        removeAll(from: "Uom")
        uoms.forEach { uom in
            self.save(new: uom)
        }
    }
    func syncProducts(_ completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        FirebaseService.data.syncProducts { result in
            switch result {
            case let .success(products):
                let cdProducts = self.transform(from: products)
                self.importNew(cdProducts)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    
    
    func transform(from fbProducts: [FBProductModel]) -> [CDProductModel] {
        
        var cdProducts: [CDProductModel] = []
        
        for product in fbProducts {
            cdProducts.append(mapper(from: product))
        }
        return cdProducts
    }
    
    func mapper(from product: FBProductModel) -> CDProductModel {
        
        return CDProductModel(id: product.id,
                              name: product.name,
                              categoryId: product.categoryId,
                              uomId: product.uomId)
    }
    
    
    
    
    
    
    
    public func importNew(_ products:[CDProductModel])  {
        if !synced {
            removeAll(from: "Product")
            synced = true
            products.forEach { product in
                self.save(new: product)
                print(product.name)
            }
        }
        
    }
    
    
    func syncStatistics(completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        FirebaseService.data.syncStatistics { result in
            switch result {
            case let .success(statistics):
                let cdStats = self.transform(from: statistics)
                self.importNew(cdStats)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    
    func transform(from stats: [ItemStatistic]) -> [CDStatisticModel] {
        
        var cdStats: [CDStatisticModel] = []
        
        for stat in stats {
            cdStats.append(mapper(from: stat))
        }
        return cdStats
    }

    func mapper(from stat: ItemStatistic) -> CDStatisticModel {
        
        return CDStatisticModel(productId: stat.productId,
                                price: stat.price,
                                outletId: stat.outletId)
    }
    
    public func importNew(_ statistics: [CDStatisticModel])  {
        removeAll(from: "Statistic")
        statistics.forEach { statistic in
            self.save(new: statistic)
        }
    }
    
    func removeAll(from entity: String) {
        let requestCategories = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: requestCategories)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            fatalError("\(entity) removing error")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
