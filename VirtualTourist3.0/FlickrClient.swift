//
//  FlickrClient.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation
import MapKit
import CoreData


class FlickrClient: NSObject {
    var totalPages: Int16?
    
    class func sharedInstance() -> FlickrClient {
        
        struct Static {
            static var sharedInstance = FlickrClient()
        }
        
        return Static.sharedInstance
    }
    
    lazy var session = {
        return URLSession.shared
    }()
    
    func downloadPhotosForPin(_ pin: Pin, completionHandler: @escaping (Bool, [[String: AnyObject]]?
        , String?) -> Void) {
        
        var randomPageNumber = pin.pagesOfPhotos
        
        func randomWithinPageLimit () -> Int {
            
            randomPageNumber = Int16(arc4random_uniform(UInt32(randomPageNumber)))
            //Flickr will reject any page above 200 because photos loaded by the search cap at 4k.
            if randomPageNumber > 200 {
                randomPageNumber = Int16(Int(arc4random_uniform(UInt32(200))))
            }
            print(randomPageNumber)
            return Int(randomPageNumber)
        }
        print("Converting to random number for parameters \(randomWithinPageLimit())")
        
        
        let parameters : [String: AnyObject] = [
            URLKeys.APIKey : API.apiKey as AnyObject,
            URLKeys.Format : API.JSONFormat as AnyObject,
            URLKeys.NoJSONCallback : 1 as AnyObject,
            URLKeys.Extras : URLValues.URLMediumPhoto as AnyObject,
            URLKeys.Latitude : pin.latitude as AnyObject,
            URLKeys.Longitude : pin.longitude as AnyObject,
            URLKeys.Page : randomWithinPageLimit() as AnyObject,
            URLKeys.PerPage : 20 as AnyObject
            
        ]
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&"
        let urlString = url + FlickrClient.escapedParameters(parameters)
        print(urlString)
        
        let request = URLRequest(url: URL(string: urlString)!)
        //        print(request)
        
        session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let data = data else {
                completionHandler(false, nil, error!.localizedDescription)
                return
            }
            
            if let error = error {
                completionHandler(false, nil, error.localizedDescription)
                return
            }
            
            var parsedObject : AnyObject?
            do {
                parsedObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            } catch {
                completionHandler(false, nil, "Was not able to parse in function getMethodWithParameters")
            }
            let parsedResponse = self.parsePhotosHelper(parsedObject)
            
            completionHandler(true, parsedResponse, error?.localizedDescription )
            
            
        }).resume()
    }
    
    func getImage(_ photoURL: String?, completionHandler:@escaping (Data?, String?) -> Void) -> URLSessionTask? {
        
        if let photoURL = photoURL {
            let url = URL(string: photoURL)!
            
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, downloadError in
                
                if let error = downloadError {
                    completionHandler(nil, error.localizedDescription)
                } else {
                    completionHandler(data!, nil)
                }
            })
            task.resume()
            return task
        } else {
            completionHandler(nil, "Path was nil")
            return nil
        }
        
    }
    
    func parsePhotosHelper(_ data: AnyObject!) -> [[String: AnyObject]]? {
        
        
        //check downloaded photos?
        
        guard let photos = data.value(forKey: "photos") as? [String: AnyObject] else {
            return nil
        }
        guard let photo = photos["photo"] as? [[String: AnyObject]] else {
            return nil
        }
        guard let numberOfPhotos = photos["pages"] as? Int else {
            return nil
        }
        
        totalPages = Int16(numberOfPhotos)
        
        print("total number of pages is \(numberOfPhotos)")
        
        // i may be wrong about this return, could be photos
        return photo
        
    }
    
    // make sure the parameters supplied are being escaped and formatted for URL
    
    class func escapedParameters (_ parameters: [String : AnyObject]) -> String {
        
        // create a default value if empty
        var urlVars = [String]()
        
        for (key, value) in parameters {
            if !(key.isEmpty) {
                let stringValue = "\(value)"
                
                let escapedValues = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                urlVars += [key + "=" + "\(escapedValues!)"]
            }
        }
        return urlVars.joined(separator: "&")
    }

}
