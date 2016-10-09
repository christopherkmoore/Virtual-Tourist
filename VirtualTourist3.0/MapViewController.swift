//
//  MapViewController.swift
//  VirtualTourist3.0
//
//  Created by modelf on 10/8/16.
//  Copyright © 2016 modelf. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    // create variable to store mkannotation and later save to coredata
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteView: UIView!
    var editButtonTapped = true
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var newPin: Pin?
    var pins = [Pin]()
    var selectedPinToPass : Pin? = nil
    
    //MARK Loading Pins
    
    func fetchAllPins() -> [Pin] {
        do {
            let fetchRequest: NSFetchRequest<Pin> = NSFetchRequest(entityName: "Pin")
            pins = try sharedContext.fetch(fetchRequest)
            return pins
        } catch {
            print("error fetching pins")
        }
        return [Pin]()
    }
    
    func loadMapPins() {
        
        mapView.removeAnnotations(pins)
        
        if mapView.annotations.count == 0 {
            if pins.count > 0 {
                mapView.addAnnotations(pins)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pins = fetchAllPins()
        
        mapView.delegate = self
        deleteView.isHidden = false
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        if mapView.annotations.count == 0 {
            loadMapPins()
        }
    }
    
    @IBAction func editPressed(_ sender: AnyObject) {
        
        if navigationItem.rightBarButtonItem?.title == "Done" {
            UIView.animate(withDuration: 0.7, animations: {
                self.mapView.frame.origin.y += self.deleteView.frame.height
            })
            navigationItem.rightBarButtonItem?.title = "Edit"
            self.editButtonTapped = true
            print("edit button is \(editButtonTapped)")
            
            CoreDataStackManager.sharedInstance().saveContext()
        } else {
            UIView.animate(withDuration: 0.7, animations: {
                self.mapView.frame.origin.y -= self.deleteView.frame.height
                
            })
            navigationItem.rightBarButtonItem?.title = "Done"
            self.editButtonTapped = false
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    func requestPhotos (_ pin: Pin ) {
        
        FlickrClient.sharedInstance().downloadPhotosForPin(pin, completionHandler: { success, photo, error in
            if (success) {
                if let data = photo {
                    DispatchQueue.main.async { [unowned self ] in
                        _ = data.map() {(item: [String:AnyObject]) -> Photos in
                            let photo = Photos(content: item, context: self.sharedContext)
                            
                            photo.pin = pin
                            
                            return photo
                        }
                        if pin.pagesOfPhotos == 0 {
                            pin.pagesOfPhotos = FlickrClient.sharedInstance().totalPages!
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
    
    func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let touchMapCoordinates = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let newMapPoint = MKPointAnnotation()
        newMapPoint.coordinate = CLLocationCoordinate2DMake(touchMapCoordinates.latitude, touchMapCoordinates.longitude)
        
        switch gestureRecognizer.state {
        case .began:
            newPin = Pin(latitude: touchMapCoordinates.latitude, longitude: touchMapCoordinates.longitude, context: self.sharedContext)
            newPin!.coordinate = touchMapCoordinates
            pins.append(newPin!)
            mapView.addAnnotation(newMapPoint)
            requestPhotos(newPin!)
            CoreDataStackManager.sharedInstance().saveContext()
            break
        default:
            return
        }
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdentifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as?MKPinAnnotationView
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView!.animatesDrop = true
            
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        guard let selectedAnnotation = view.annotation else {return}
        
        
        func findSelectedPin() -> Pin? {
            
            for pin in pins {
                if pin.latitude == selectedAnnotation.coordinate.latitude && pin.longitude == selectedAnnotation.coordinate.longitude {
                    
                    selectedPinToPass = pin
                    return selectedPinToPass!
                }
            }
            return nil
        }
        
        if editButtonTapped == true {
            if let value = findSelectedPin() {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
                controller.pin = value
                self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            print(pins)
            if let value = findSelectedPin() {
                sharedContext.delete(value)
                CoreDataStackManager.sharedInstance().saveContext()
            }
            self.mapView.removeAnnotation(selectedAnnotation)
        }
        
    }
}

