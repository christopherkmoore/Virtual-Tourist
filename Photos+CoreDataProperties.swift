//
//  Photos+CoreDataProperties.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation
import CoreData

extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var filePath: String?
    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imgURL: String?
    @NSManaged public var pin: Pin?

}
