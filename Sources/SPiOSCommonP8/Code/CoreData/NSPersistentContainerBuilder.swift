//
//  PersistentContainerBuilder.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 08/11/26.
//


import CoreData

public class NSPersistentContainerBuilder {
    
    // Configuration properties
    private let modelName: String
    private var storeType: String = NSSQLiteStoreType
    private var storeURL: URL?
    private var shouldMigrateAutomatically: Bool = true
    private var shouldInferMapping: Bool = true
    private var shouldAddAsynchronously: Bool = false
    private var enableWALPragma: Bool = true
    private var readOnly: Bool = false
    private var cloudKitContainerIdentifier: String?
    
    public init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Builder Methods
    
    public func setStoreType(_ type: String) -> NSPersistentContainerBuilder {
        self.storeType = type
        return self
    }
    
    public func setStoreURL(_ url: URL) -> NSPersistentContainerBuilder {
        self.storeURL = url
        return self
    }
    
    public func setAutomaticMigration(_ enabled: Bool) -> NSPersistentContainerBuilder {
        self.shouldMigrateAutomatically = enabled
        return self
    }
    
    public func setInferMappingModel(_ enabled: Bool) -> NSPersistentContainerBuilder {
        self.shouldInferMapping = enabled
        return self
    }
    
    public func setAsynchronousLoading(_ enabled: Bool) -> NSPersistentContainerBuilder {
        self.shouldAddAsynchronously = enabled
        return self
    }
    
    public func setWALMode(_ enabled: Bool) -> NSPersistentContainerBuilder {
        self.enableWALPragma = enabled
        return self
    }
    
    public func setReadOnly(_ enabled: Bool) -> NSPersistentContainerBuilder {
        self.readOnly = enabled
        return self
    }
    
    public func enableCloudKit(containerIdentifier: String) -> NSPersistentContainerBuilder {
        self.cloudKitContainerIdentifier = containerIdentifier
        return self
    }
    
    // MARK: - Build Execution
    
     func build() -> NSPersistentContainer {
        let container: NSPersistentContainer
        
        // 1. Instantiate standard container or CloudKit container
        if let cloudKitID = cloudKitContainerIdentifier {
            container = NSPersistentCloudKitContainer(name: modelName)
            
            // Configure CloudKit options if using NSPersistentCloudKitContainer
            let description = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitID)
            container.persistentStoreDescriptions = [description]
        } else {
            container = NSPersistentContainer(name: modelName)
        }
        
        // 2. Configure Store Description
        let description: NSPersistentStoreDescription
        
        if let customURL = storeURL {
            description = NSPersistentStoreDescription(url: customURL)
        } else if storeType == NSInMemoryStoreType {
            description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let defaultURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(modelName).sqlite")
            description = NSPersistentStoreDescription(url: defaultURL)
        }
        
        // 3. Apply all flags and settings
        description.type = storeType
        description.shouldAddStoreAsynchronously = shouldAddAsynchronously
        description.shouldMigrateStoreAutomatically = shouldMigrateAutomatically
        description.shouldInferMappingModelAutomatically = shouldInferMapping
        description.isReadOnly = readOnly
        
        // Enable WAL mode for SQLite databases to optimize concurrency
        if storeType == NSSQLiteStoreType && enableWALPragma {
            description.setOption(true as NSNumber, forKey: NSSQLitePragmasOption)
        }
        
        container.persistentStoreDescriptions = [description]
        
        return container
    }
}
