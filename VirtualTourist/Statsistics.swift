//
//  Stats.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/27/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import CoreData

@objc(Statistics)
class Statistics: NSManagedObject {
    
    
    @NSManaged var locationsAdded: Int64
    @NSManaged var photosDisplayed: Int64
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(locations: Int64 ,photos: Int64 , context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Statistics", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        locationsAdded = locations
        photosDisplayed = photos
    } 
    
}