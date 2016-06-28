//
//  Photo.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/27/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
class Photo: NSManagedObject {
    
    struct PhotoKeys {
        static let Title = "title"
        static let ImagePath = "imagePath"
    }
    
    
    @NSManaged var title: String
    @NSManaged var imagePath: String
    @NSManaged var location:Location?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        title = dictionary[PhotoKeys.Title] as! String
        
        if let pathForImage = dictionary[PhotoKeys.ImagePath] as? String {
            imagePath = pathForImage
        }
        
    }
    
    var image: UIImage? {
        get {
            return Flickr.Caches.imageCache.imageWithIdentifier(imagePath)
        } set {
            Flickr.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }
}
    