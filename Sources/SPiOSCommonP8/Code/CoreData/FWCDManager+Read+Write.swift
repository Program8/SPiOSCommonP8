//
//  FWCDManager+Read+Write.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 13/11/26.
//

import Foundation
import CoreData

extension FWCDManager {
    public enum ContextType{
        case viewContext,backgroundContext
        
    }
    public func context(for type: ContextType) -> NSManagedObjectContext {
        switch type {
        case .viewContext:
            return container.viewContext
        case .backgroundContext:
            return container.newBackgroundContext()
        }
    }
    public func fetch<T: NSManagedObject>(for request: NSFetchRequest<T>, in type: ContextType) throws -> [T] {
        return try context(for: type).fetch(request)
    }
    public func save(context:NSManagedObjectContext)throws{
        if context.hasChanges {
            try context.save()
        }
    }
}
