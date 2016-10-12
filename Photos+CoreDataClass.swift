//
//  Photos+CoreDataClass.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Photos: NSManagedObject {
    

    //create inits TO DO - need to figure out how to init ID, IMGURL -- potentially PIN
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    // the init and use of map to initialize the photos should be credited to a fellow udacian. It took me a while to understand how it worked, but I can see no cleaner way to get the job done.
    
    init(content: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Photos", in: context)!
        super.init(entity: entity, insertInto: context)
        
        id = content["id"] as? String
        imgURL = content["url_m"] as? String

    }
}
