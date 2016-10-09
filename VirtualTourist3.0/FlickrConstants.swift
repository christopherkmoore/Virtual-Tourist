//
//  FlickrConstants.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct API {
        static var apiKey = "78d64953560d1f35110efc61a84a614a"
        static var myPreciouuuuss = "a0e682bec72abc66"
        static var coordinateLat : Double = 40.0
        static var coordinateLong : Double = -120.0
        static var JSONFormat = "json"
    }
    struct URLKeys {
        static let APIKey = "api_key"
        static let BoundingBox = "bbox"
        static let Format = "format"
        static let Extras = "extras"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    struct URLValues {
        static let URLMediumPhoto = "url_m"
    }
    
    struct JSONResponseKeys {
        static let Status = "stat"
        static let Code = "code"
        static let Message = "message"
        static let Pages = "pages"
        static let Photos = "photos"
        static let Photo = "photo"
    }
    struct Methods {
        static let Search = "flickr.photos.search"
    }
}
