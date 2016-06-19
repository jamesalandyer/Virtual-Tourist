//
//  MapVC.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var topNavItem: UINavigationItem!
    
    var longPress: UILongPressGestureRecognizer!
    var editMode = false
    
    var fetchedResultsController: NSFetchedResultsController!
    
    var downloadedImages: [[String: String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        mapView.delegate = self
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        mapView.addAnnotations(fetchAllPins())
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if editButton.title == "Edit" {
            editButton.title = "Done"
            deleteLabel.hidden = false
            editMode = true
        } else {
            editButton.title = "Edit"
            deleteLabel.hidden = true
            editMode = false
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = purpleColor
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if views.count == 1 {
            
            let view = views[0]
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
            
            // Animate drop
            let delay = 0.03 * Double(1)
            UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
                }, completion:{ (Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        view.transform = CGAffineTransformMakeScale(1.0, 0.6)
                        
                        }, completion: { (Bool) in
                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                view.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
                    
            })
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let pin = view.annotation as! Pin
        
        if editMode {
            fetchedResultsController.managedObjectContext.deleteObject(pin)
            mapView.removeAnnotation(pin)
        } else {
            performSegueWithIdentifier("showAlbum", sender: pin)
        }
    }
    
    func fetchAllPins() -> [Pin] {
        attemptFetch(fetchedResultsController)
        
        let allPins = fetchedResultsController.fetchedObjects as! [Pin]
        
        return allPins
    }
    
    func addAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: fetchedResultsController.managedObjectContext)
            
            FlickrClient.sharedInstance.getImagesForPin(pin, context: fetchedResultsController.managedObjectContext)
            
            mapView.addAnnotation(pin)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlbum" {
            if let albumVC = segue.destinationViewController as? AlbumVC {
                
                let fetchRequest = NSFetchRequest(entityName: "Photo")
                
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "smallImageURL", ascending: false), NSSortDescriptor(key: "largeImageURL", ascending: true)]
                
                let pin = sender as! Pin
                
                let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
                
                fetchRequest.predicate = predicate
                
                let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: fetchedResultsController.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                
                albumVC.fetchedResultsController = fc
                
                albumVC.pin = pin
            }
        }
    }

}

