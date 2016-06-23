//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
// 
// static let secret: String = "b266f64b25061090"

import UIKit

// MARK: Flickr Parameter Keys
struct FlickrParameterKeys {
    static let Method = "method"
    static let APIKey = "api_key"
    static let Extras = "extras"
    static let Format = "format"
    static let NoJSONCallback = "nojsoncallback"
    static let Text = "text"
    static let BoundingBox = "bbox"
    static let Page = "page"
}

// MARK: Flickr Parameter Values
struct FlickrParameterValues {
    static let APIKey = "ab761ba5da91b894ed21c06df0a77394"
    static let ResponseFormat = "json"
    static let DisableJSONCallback = "1" /* 1 == "yes", 0 == "no" */
    static let GeoMethod: String = "flickr.photos.geo.photosForLocation"
    static let MediumURL = "url_m"
    static let UseSafeSearch = "1"
}

// MARK: Flickr Response Keys
struct FlickrResponseKeys {
    static let Status = "stat"
    static let Photos = "photos"
    static let Photo = "photo"
    static let Title = "title"
    static let MediumURL = "url_m"
    static let Pages = "pages"
    static let Total = "total"
}

// MARK: Flickr Response Values
struct FlickrResponseValues {
    static let OKStatus = "ok"
}

// MARK: Flickr URL Constants
struct FlickrURLConstants {
    static let Scheme: String = "https"
    static let Host: String = "api.flickr.com"
    static let Path: String = "services/rest"
}

// MARK: - Flickr URL MEthods
struct FlickrURLMethods {
    static let Method: String = "method"
    static let Lat: String = "lat"
    static let Lon: String = "lon"
    static let Extras: String = "url_m"
    static let Token: String = "auth_token"
    static let Api: String = "api_key"
    static let Format: String = "format"
}

