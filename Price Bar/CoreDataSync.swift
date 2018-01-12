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
    
    public func importNew(_ uoms:[ItemUom])  {
        removeAll(from: "Uom")
        uoms.forEach { uom in
            self.save(new: uom)
        }
    }
    func syncProducts(_ completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        FirebaseService.data.syncProducts { result in
            switch result {
            case let .success(products):
                self.importNew(products)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    
    public func importNew(_ products:[ShopItem])  {
        removeAll(from: "Product")
        products.forEach { product in
            self.save(new: product)
        }
    }
    
    
    func syncStatictics(completion: @escaping (ResultType<Bool, CoreDataErrors>)->()) {
        
        FirebaseService.data.syncStatistics { result in
            switch result {
            case let .success(statistics):
                self.importNew(statistics)
                completion(ResultType.success(true))
            case let .failure(error):
                completion(ResultType.failure(CoreDataErrors.error(error.localizedDescription)))
            }
        }
    }
    
    
    public func importNew(_ statistics: [ItemStatistic])  {
        removeAll(from: "Statistics")
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
