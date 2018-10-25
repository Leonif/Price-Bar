//
//  CoreDataStack.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 10/13/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataErrors: Error {
    case error(String)
}

class CoreDataStack {
    private var modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()

    func saveContext () {
        guard self.managedContext.hasChanges else { return }

        do {
            try self.managedContext.save()
        } catch {
            let error = error as NSError
            debugPrint("Unresolved error \(error), \(error.userInfo)")
        }
    }

}
