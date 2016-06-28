//
//  ManagingCoreData.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/27/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import CoreData

private let SQLITE_FLIE_NAME = "VirtualTourist.sqlite"

class ManagingCoreData {
    
    class func sharedInstance() -> ManagingCoreData {
        struct DataStatic {
            static let instance = ManagingCoreData()
        }
        
        return DataStatic.instance
    }
    
    lazy var applicationDirect: NSURL = {
        
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return url[ url.count-1 ]
    }()
    
    lazy var managingModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        
    }()
    
    lazy var persisentStoring: NSPersistentStoreCoordinator? = {
        
        var opera: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managingModel)
        let url = self.applicationDirect.URLByAppendingPathComponent(SQLITE_FLIE_NAME)
        
        var error: NSError? = nil
        
        do {
            try opera!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var persistError as NSError {
            error = persistError
            opera = nil
            
            var dict = [NSObject : AnyObject]()
            dict[NSLocalizedDescriptionKey] = DataMessageErrorss.saveDataError
            dict[NSLocalizedFailureReasonErrorKey] = DataMessageErrorss.loadDataError
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            
            NSLog("Error: \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return opera
        
    }()
    
    lazy var managingObjectContent: NSManagedObjectContext? = {
        
        let coordinator = self.persisentStoring
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContent () {
        
        if let context = self.managingObjectContent {
            
            var error: NSError? = nil
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Error: \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}

// MARK: - Managing Core Data (Deleting)
extension ManagingCoreData {
    
    func deleteLocObects(location:Location) {
        if let context = self.managingObjectContent {
            
            var error: NSError? = nil
            context.deleteObject(location)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Error: \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func deleteFlies(filePath: String)  {
        let manager = NSFileManager.defaultManager()
        
        do {
            try manager.removeItemAtPath(filePath)
        } catch{
            print("File wasn't deleted: \(filePath)")
        }
    }
    
    func deletePicObject(photo:Photo) {
        if let context = self.managingObjectContent {
            
            var error: NSError? = nil
            deleteFlies(Flickr.sharedInstance().imagePath((photo.imagePath as NSString).lastPathComponent))
            context.deleteObject(photo)
            if context.hasChanges {
                do {
                    try context.save()
                } catch let objectError as NSError {
                    error = objectError
                    NSLog("Error: \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}
        