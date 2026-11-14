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
    
    private init() {}
    
    /// Loads a standard persistent container using a model file name.
    public func setupCoreDataStack(coreDataModelFileName: String)async throws {
        container = NSPersistentContainer(name: coreDataModelFileName)
        try await loadPersistentStores()
    }
    
    /// Loads a persistent container configured via a container builder.
    public func setupCoreDataStack(builder: NSPersistentContainerBuilder)async throws {
        container = builder.build()
        try await loadPersistentStores()
    }
    private func loadPersistentStores()async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { [weak self] persistentStoreDescription, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.mLogError(msg: "Failed to load persistent store: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    
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
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

