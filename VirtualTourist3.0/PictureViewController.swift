//
//  PictureViewController.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData


class PictureViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPicturesLabel: UILabel!
    
    var pin: Pin!
    
    var insertedIndexPaths : [IndexPath]!
    var deletedIndexPaths : [IndexPath]!
    var updatedIndexPaths : [IndexPath]!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedPhotosResultsController: NSFetchedResultsController<Photos> = {
        
        let fetchRequest: NSFetchRequest<Photos> = NSFetchRequest(entityName: "Photos")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        
        let fetchedPhotosResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil,cacheName: nil)
        
        return fetchedPhotosResultsController
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedPhotosResultsController.performFetch()
        } catch {
            fatalError("Failed to load the saved photos.")
        }
        
        if pin.photos!.count == 0 {
            requestPhotos()
        }
        
        noPicturesLabel.isHidden = true
        fetchedPhotosResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadMapInformation()
        
    }
    let darkGreyPlaceholderUIImage: UIImage = {
        var rect: CGRect = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 500.0)
        UIGraphicsBeginImageContext(rect.size)
        var context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.darkGray.cgColor)
        context.fill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func loadMapInformation () {
        
        if mapView.annotations.count > 1 {
            mapView.removeAnnotations(mapView.annotations)
        }
        self.mapView.addAnnotation(pin)
        self.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(pin.latitude, pin.longitude), span: MKCoordinateSpanMake(1.0, 1.0)), animated: true)
    }
    
    func requestPhotos () {
    
        FlickrClient.sharedInstance().downloadPhotosForPin(self.pin, completionHandler: { success, photo, error in
            if (success) {
                if let data = photo {
                    DispatchQueue.main.async { [unowned self ] in
                        _ = data.map() {(item: [String:AnyObject]) -> Photos in
                            let photo = Photos(content: item, context: self.sharedContext)
                            
                            photo.pin = self.pin
                            
                            return photo
                        }
                        if self.pin.pagesOfPhotos == 0 {
                            self.pin.pagesOfPhotos = FlickrClient.sharedInstance().totalPages!
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
            else {
                print(error!)
            }
            
        })
    }
    
    // this looks just wrong...
    
    @IBAction func newCollection(_ sender: AnyObject) {

        let new = fetchedPhotosResultsController.fetchedObjects!
        for item in new {
            sharedContext.delete(item)
        }
        requestPhotos()
        
        
        // problem here, not reloading collectionView.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedPhotosResultsController.fetchedObjects?.count
        //        print("Number of photos returned from fetchedResultsController #\(sectionInfo)")
        
        // If numberOfObjects is not zero, hide the noImagesLabel
        //        noImagesLabel.hidden = sectionInfo.numberOfObjects != 0
        
        return sectionInfo!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedPhotosResultsController.object(at: indexPath) 
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        // prevents views from animating upon reload. uncomment to keep static boxes
        cell.imageView.image = darkGreyPlaceholderUIImage
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        
        
        if photo.imgURL == ""  {
            cell.imageView.image = UIImage(named: "noImage")
            
        }
            
        else {
            _ = FlickrClient.sharedInstance().getImage(photo.imgURL) { (data, error) in
                
                var image: UIImage!
                
                
                guard error == nil else {
                    image = UIImage(named: "noImage")
                    return
                }
                
                if let data = data {
                    image = UIImage(data: data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.isHidden = true
                        }
                        
                    )}
            }
        }
        
        return cell
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .delete:
            deletedIndexPaths.append(indexPath!)
            
            break
            
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            }, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedPhotosResultsController.object(at: indexPath) 
        sharedContext.delete(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
}
    

