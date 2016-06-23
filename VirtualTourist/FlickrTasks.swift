//
//  FlickrTasks.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit

extension DetailViewController {
    
    // MARK: Helper for Creating a URL from Parameters
    
    internal func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = FlickrURLConstants.Scheme
        components.host = FlickrURLConstants.Host
        components.path = FlickrURLConstants.Path
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    // MARK: Flickr API
    
//    private func displayImageFromFlickr(methodParameters: [String:AnyObject]) {
//        
//        let session = NSURLSession.sharedSession()
//        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
//        let task = session.dataTaskWithRequest(request) { (data, response, error) in
//            
//            guard (error == nil) else {
//                self.displayError("There was an error with the data task request: \(error)")
//                return
//            }
//            
//            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//                self.displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            let parseResult: AnyObject!
//            do {
//                parseResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
//            } catch let error {
//                fatalError("\(error)")
//            }
//            
//            guard let photosDictionary = parseResult[FlickrResponseKeys.Photos] as? [String:AnyObject], photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
//                self.displayError("Can not find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(parseResult)")
//                return
//            }
//            
//            if photoArray.count == 0 {
//                self.displayError("No photos found. Search again.")
//                self.showAlert("No Match Found", message: "No photos found, please search again")
//            } else {
//                
//                let randomPhotoIndex = self.randomNumberGenerator(photoArray.count)
//                let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
//                
//                guard let imageUrlString = photoDictionary[FlickrResponseKeys.MediumURL] as? String, let photoTitle = photoDictionary[FlickrResponseKeys.Title] as? String else {
//                    self.displayError("Cannot find key '\(FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
//                    return
//                }
//                
//                let imageUrl = NSURL(string: imageUrlString)
//                if let imageData = NSData(contentsOfURL: imageUrl!) {
//                    self.photoImageView.image = UIImage(data: imageData)
//                    self.photoTitleLabel.text = photoTitle
//                } else {
//                    self.displayError("Image does not exist at \(imageUrl)")
//                }
//            }
//            
//        }
//        task.resume()
//    }
    
    
//    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber: Int) {
//        
//        var methodParametersWithPageNumber = methodParameters
//        methodParametersWithPageNumber[FlickrParameterKeys.Page] = withPageNumber
//        
//        let session = NSURLSession.sharedSession()
//        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
//        let task = session.dataTaskWithRequest(request) { (data, response, error) in
//            guard (error == nil) else {
//                self.displayError("There was an error with the data task request: \(error)")
//                return
//            }
//            
//            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
//                self.displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            let parseResult: AnyObject!
//            do {
//                parseResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
//            } catch let error {
//                fatalError("\(error)")
//            }
//            
//            
//            guard let stat = parseResult[FlickrResponseKeys.Status] as? String where stat == FlickrResponseValues.OKStatus else {
//                self.displayError("Flickr API returned an error. See error code and message \(parseResult)")
//                return
//            }
//            
//            guard let photosDictionary = parseResult[FlickrResponseKeys.Photos] as? [String:AnyObject], photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
//                self.displayError("Can not find keys '\(FlickrResponseKeys.Photos)' and '\(FlickrResponseKeys.Photo)' in \(parseResult)")
//                return
//            }
//            
//            if photoArray.count == 0 {
//                self.displayError("No photos found. Search again.")
//                self.showAlert("No Match Found", message: "No photos found, please search again")
//            } else {
//                
//                guard (photosDictionary[FlickrResponseKeys.Pages] as? Int) != nil else {
//                    self.displayError("Can not find key '\(FlickrResponseKeys.Pages)' in \(photosDictionary)")
//                    return
//                }
//                
//                let randomPhotoIndex = self.randomNumberGenerator(photoArray.count)
//                let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
//                
//                guard let imageUrlString = photoDictionary[FlickrResponseKeys.MediumURL] as? String, let photoTitle = photoDictionary[FlickrResponseKeys.Title] as? String else {
//                    self.displayError("Cannot find key '\(FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
//                    return
//                }
//                
//                let imageUrl = NSURL(string: imageUrlString)
//                if let imageData = NSData(contentsOfURL: imageUrl!) { performUIUpdatesOnMain() {
//                    self.photoImageView.image = UIImage(data: imageData)
//                    self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                    self.setUIEnabled(true)
//                    }
//                } else {
//                    self.displayError("Image does not exist at \(imageUrl)")
//                }
//            }
//        }
//        task.resume()
//    }

    
    
    // Error messages
    func displayError(error: String) {
        print(error)
    }
    
    // Random number generator
    func randomNumberGenerator(max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    // Alerts
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: title, style: .Default, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}