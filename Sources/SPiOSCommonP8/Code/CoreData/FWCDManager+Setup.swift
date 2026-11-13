//
//  FWCDManager.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 08/11/26.
//

import CoreData

public class FWCDManager: FWLoggerDelegate {
    
    @MainActor
    public static let shared = FWCDManager()
    
     var container: NSPersistentContainer!
    
    /// Typealias for the Core Data container loading completion handler
    public typealias CompletionHandler = (Error?) -> Void
    
    private init() {}
    
    /// Loads a standard persistent container using a model file name.
    public func setupCoreDataStack(coreDataModelFileName: String, completion: @escaping CompletionHandler) {
        container = NSPersistentContainer(name: coreDataModelFileName)
        loadPersistentStores(completion: completion)
    }
    
    /// Loads a persistent container configured via a container builder.
    public func setupCoreDataStack(builder: NSPersistentContainerBuilder, completion: @escaping CompletionHandler) {
        container = builder.build()
        loadPersistentStores(completion: completion)
    }
    
    private func loadPersistentStores(completion: @escaping CompletionHandler) {
        container.loadPersistentStores { [weak self] persistentStoreDescription, error in
            guard let self = self else { return }
            
            if let error = error {
                self.mLogError(msg: "Failed to load persistent store: \(error.localizedDescription)")
            } else {
                let description = persistentStoreDescription
                // Check if persistent history tracking is enabled in options
                let historyTrackingEnabled: String = {
                    if let trackingValue = description.options[NSPersistentHistoryTrackingKey] as? NSNumber {
                        return trackingValue.boolValue ? "Yes" : "No"
                    }
                    return "No"
                }()
                
                // Get SQLite pragmas if available
                let sqlitePragmas = description.options[NSSQLitePragmasOption] ?? ("None") as NSObject
                
                // Printing all details of persistentStoreDescription
                self.mLogInfo(msg: """
                Persistent Store Loaded Successfully:
                - Type: \(description.type)
                - Configuration Name: \(description.configuration ?? "nil")
                - URL: \(description.url?.absoluteString ?? "nil")
                - Options: \(description.options)
                - Read-Only: \(description.isReadOnly)
                - SQLite Pragmas: \(sqlitePragmas)
                - History Tracking Enabled: \(historyTrackingEnabled)
                - Full Description: \(description)
                """)
            }
            
            completion(error)
        }
    }
    
}

