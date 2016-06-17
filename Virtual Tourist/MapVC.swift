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
    var places = [MKPointAnnotation]()
    var editMode = false
    
    var fetchedResultsController : NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
        
        setAnnotationsFromPins()
        
        mapView.delegate = self
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        longPress.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(longPress)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
        for (index, view) in views.enumerate() {
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point: MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue
            }
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
            
            // Animate drop
            let delay = 0.03 * Double(index)
            UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        view.transform = CGAffineTransformMakeScale(1.0, 0.6)
                        
                        }, completion: {(Bool) in
                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                view.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
                    
            })
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if editMode {
            if let annotation = view.annotation {
                mapView.removeAnnotation(annotation)
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = annotation.coordinate
                removePlace(pointAnnotation)
            } else {
                print("ERROR")
            }
        } else {
            performSegueWithIdentifier("showAlbum", sender: nil)
        }
    }
    
    func addAnnotation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            self.mapView.addAnnotation(annotation)
            places.append(annotation)
            
            let pin = Pin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, context: fetchedResultsController.managedObjectContext)
            print(pin)
        }
    }
    
    func removePlace(annotation: MKPointAnnotation) {
        for (index, place) in places.enumerate() {
            if place.coordinate.latitude == annotation.coordinate.latitude && place.coordinate.longitude == annotation.coordinate.longitude {
                places.removeAtIndex(index)
                break
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAlbum" {
            if let albumVC = segue.destinationViewController as? AlbumVC {
                albumVC.photoAlbum = "transfer"
            }
        }
    }
    
    func setAnnotationsFromPins() {
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
            places = []
            
            for pin in pins {
                let mapPin = pin.convertToMapPin(pin)
                
                places.append(mapPin)
            }
            
            mapView.addAnnotations(places)
        }
    }

}

