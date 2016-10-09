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
        
        if imgURL == nil {
            imgURL = "not nil please"
        }
        if imgURL != "" || imgURL != nil {
            filePath = URL(string: imgURL! as String)!.lastPathComponent
            print("File path = \(filePath)")
            print("imgURL = \(imgURL)")
        }
        
    }
    
    
    
    // deletion method
    
    func deletePhotoAtDisk() -> Bool {
        
        do {
            let path = pathForIdentifier()
            
            if let path = path {
                
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: path) {
                    try fileManager.removeItem(atPath: path)
                }
            }
            
            return true
            
        } catch {
            print("\(error)")
            return false
        }
        
    }
    
    //path finding func
    
    // loading function from path
    
    // saving function from path
    
    func pathForIdentifier() -> String? {
        if let path = filePath {
            let documentsDirectoryURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            return documentsDirectoryURL.appendingPathComponent(path).path
        }
        return nil
    }
    
    func loadImageWithIdentifier () -> UIImage? {
        let path = pathForIdentifier()
        
        if let path = path {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return UIImage(data: data)
            }
        }
        
        return nil
    }
    
    func storeImage(_ value: UIImage!) {
        
        let path = pathForIdentifier()
        
        if let path = path {
            let data = UIImageJPEGRepresentation(value, 0.0)!
            try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
        
    }
    
    
}
