//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/27/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Flickr: NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func populateLocationPhotos(let location:Location,completionHandler: (success: Bool , array: [[String]]?, error: String?) -> Void) {
        
        var page: Int = 1
        
        if let p = location.pages {
            page = Int(arc4random_uniform(UInt32(Double(p)))) + 1
        }
        
        let resource = Flickr.FlickrConstants.BASE_URL
        
        let methodParameters = [
            Flickr.FlickrConstantsArguments.method: Flickr.FlickrConstants.METHOD_NAME,
            Flickr.FlickrConstantsArguments.apiKey: Flickr.FlickrConstants.API_KEY,
            Flickr.FlickrConstantsArguments.bbox: getBbox(location),
            Flickr.FlickrConstantsArguments.safeSearch: Flickr.FlickrConstants.SAFE_SEARCH,
            Flickr.FlickrConstantsArguments.extras: Flickr.FlickrConstants.EXTRAS,
            Flickr.FlickrConstantsArguments.format: Flickr.FlickrConstants.FORMAT,
            Flickr.FlickrConstantsArguments.noJsonCallBack: Flickr.FlickrConstants.NO_JSON_CALLBACK,
            Flickr.FlickrConstantsArguments.perPage:Flickr.FlickrConstants.MAX_PER_PAGE,
            Flickr.FlickrConstantsArguments.page:String(page)
        ]
        
        Flickr.sharedInstance().taskForResource(resource, parameters: methodParameters) { JSONResult, error  in
            guard (error != nil) else {
                if let photosDictionary = JSONResult.valueForKey(Flickr.FlickrJsonResponseKeys.photos) as? [String: AnyObject] {
                    if let photosArray = photosDictionary[Flickr.FlickrJsonResponseKeys.photo] as? [[String: AnyObject]] {
                        
                        let totalPhotosVal = photosArray.count
                        if totalPhotosVal > 0 {
                            var noPhotosToDisplay = totalPhotosVal
                            if totalPhotosVal > Flickr.FlickrConstants.maxNumberOfImagesDisplayed {
                                noPhotosToDisplay = Flickr.FlickrConstants.maxNumberOfImagesDisplayed
                            }
                            
                            if let totalPhotos = photosDictionary[Flickr.FlickrJsonResponseKeys.pages] as? Int {
                                dispatch_async(dispatch_get_main_queue()) {
                                    location.pages = totalPhotos
                                }
                            }
                            
                            var listPhotos: [Int] = []
                            var helperArray = [[String]]()
                            
                            for _ in 0 ..< noPhotosToDisplay {
                                
                                var randomPhotoIndex = self.randNumGenerator(photosArray.count)
                                while listPhotos.contains(randomPhotoIndex) {
                                    randomPhotoIndex = self.randNumGenerator(photosArray.count)
                                }
                                
                                listPhotos.append(randomPhotoIndex)
                                
                                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
                                let photoTitle = photoDictionary[Flickr.FlickrJsonResponseKeys.title] as! String
                                let imageUrlString = photoDictionary[Flickr.FlickrJsonResponseKeys.imageType] as! String
                                helperArray.append([photoTitle,imageUrlString])
                            }
                            completionHandler(success: true, array:helperArray, error: nil)
                        } else {
                            completionHandler(success: false, array: nil, error: NetworkErrorMessages.noPhotos)
                        }
                    } else {
                        completionHandler(success: false, array: nil, error: NetworkErrorMessages.noPhotos)
                    }
                    
                }
                return
            }
        }
    }
    
    func downloadImageAndSetCell(let imagePath:String,let cell:CollectionViewCell,completionHandler: (success: Bool, errorString: String?) -> Void){
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                _ = Flickr.errorForData(data, response: response, error: error)
                completionHandler(success: false, errorString: "Didn't download image \(imagePath)")
            } else {
                let image = UIImage(data: data!)
                
                NSKeyedArchiver.archiveRootObject(image!,toFile: self.imagePath((imagePath as NSString).lastPathComponent))
                dispatch_async(dispatch_get_main_queue()){
                    cell.collectionImageView.image = image
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        
        task.resume()
        
    }
    
    func imagePath( selectedFilename:String) ->String{
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent(selectedFilename).path!
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return ManagingCoreData.sharedInstance().managingObjectContent!
    }
    
    func getBbox(let location:Location) -> String{
        let maxLong:NSNumber = (location.longitude as Double) + Flickr.FlickrConstants.boxSideLength
        let maxLat:NSNumber = (location.latitude as Double) + Flickr.FlickrConstants.boxSideLength
        let lat = "\(location.latitude)"
        let long = "\(location.longitude)"
        let a = long + "," + lat + "," + "\(maxLong)" + "," + "\(maxLat)"
        return a
    }
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        let mutableParameters = parameters
        let mutableResource = resource + Flickr.escapedParameters(mutableParameters)
        
        let urlString = mutableResource
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                _ = Flickr.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                Flickr.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            if let errorMessage = parsedResult["msg"] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: DataMessageErrorss.domainError, code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            } catch let error as NSError {
                parsingError = error
                parsedResult = nil
            }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("\"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    class func sharedInstance() -> Flickr {
        
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        
        return Singleton.sharedInstance
    }
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}

extension Flickr {
    
    func randNumGenerator(count: Int) -> Int {
        return Int(arc4random_uniform(UInt32(count)))
    }
    
}
