//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/27/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

extension Flickr {
    
    struct FlickrConstants {
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "1d439920fc517e5eed7510dd10ff2d5e"
        static let GALLERY_ID = "5704-72157622566655097"
        static let EXTRAS = "url_m"
        static let FORMAT = "json"
        static let SAFE_SEARCH = "1"
        static let MAX_PER_PAGE = "250"
        static let NO_JSON_CALLBACK = "1"
        static let boxSideLength = 0.05
        static let maxNumberOfImagesDisplayed = 24     }
    
    struct FlickrConstantsArguments {
        
        static let method = "method"
        static let apiKey = "api_key"
        static let bbox = "bbox"
        static let safeSearch = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let noJsonCallBack = "nojsoncallback"
        static let perPage = "per_page"
        static let page = "page"
    }
    
    struct FlickrJsonResponseKeys {
        
        static let photo = "photo"
        static let photos = "photos"
        static let pages = "pages"
        static let title = "title"
        static let imageType = "url_m"
    }
    
}
