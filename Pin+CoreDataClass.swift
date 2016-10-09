//
//  Pin+CoreDataClass.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject, MKAnnotation {
    
    // Insert code here to add functionality to your managed object subclass
    
    fileprivate var _coords: CLLocationCoordinate2D?
    public var coordinate: CLLocationCoordinate2D {
        
        set {
            willChangeValue(forKey: "coordinate")
            _coords = newValue
            
            // set the new values of the lat and long
            if let coord = _coords {
                latitude = coord.latitude
                longitude = coord.longitude
            }
            
            didChangeValue(forKey: "coordinate")
        }
        
        get {
            if _coords == nil {
                _coords = CLLocationCoordinate2DMake(latitude, longitude)
            }
            
            return _coords!
        }
    }
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            super.init(entity: entity, insertInto: context)
            
            self.latitude = latitude
            self.longitude = longitude
            
            coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            pagesOfPhotos = 0
        } else {
            fatalError("Unable to find Entity Name")
        }
        
    }
    
}
