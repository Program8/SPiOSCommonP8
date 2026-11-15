//
//  FWCDManager+Read+Write.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 13/11/26.
//

import Foundation
import CoreData

public extension FWCDManager {
    
    public func context(for type: ContextType) -> NSManagedObjectContext {
        switch type {
        case .viewContext:
            return container.viewContext
        case .backgroundContext:
            return container.newBackgroundContext()
        }
    }
    public func fetch<T: NSManagedObject>(for request: NSFetchRequest<T>, context: NSManagedObjectContext) throws -> [T] {
        return try context.fetch(request)
    }
    public func save(context:NSManagedObjectContext)throws{
        if context.hasChanges {
            try context.save()
        }
    }
}
