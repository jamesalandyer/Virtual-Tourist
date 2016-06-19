//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Page = "page"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let Radius = "radius"
            static let PerPage = "per_page"
        }
        
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "cdeab233081b79f3becc1a9fc685f024"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1"
            static let MediumURL = "url_m"
            static let LargeURL = "url_c"
            static let UseSafeSearch = "1"
            static let PerPage = "50"
            static let Radius = "10"
        }
        
        struct FlickrResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let MediumURL = "url_m"
            static let LargeURL = "url_c"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
    }
    
}