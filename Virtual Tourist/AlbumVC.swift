//
//  AlbumVC.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    //Outlets
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var editButton: UIBarButtonItem!
    @IBOutlet weak private var newAlbum: UIBarButtonItem!
    @IBOutlet weak private var noPhotosLabel: UILabel!
    
    //Properties
    var pin: Pin!
    private var editMode = false
    private var selectedItems = [NSIndexPath]()
    
    private var insertedIndexPaths: [NSIndexPath]!
    private var deletedIndexPaths: [NSIndexPath]!
    private var updatedIndexPaths: [NSIndexPath]!
    
    var fetchedResultsController: NSFetchedResultsController!
    var sharedContext = CoreDataStack.stack.context
    
    //MARK: - Stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "smallImageURL", ascending: false), NSSortDescriptor(key: "largeImageURL", ascending: true)]
        
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
        }
        
        fetchedResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        establishFlowLayout()
        mapView.addAnnotation(pin)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        noPhotosLabel.hidden = true
        
        collectionView.reloadData()
        
        if collectionView.numberOfItemsInSection(0) == 0 {
            self.noPhotosLabel.text = "No Photos To Show"
            noPhotosLabel.hidden = false
            editButton.enabled = false
        }
    }
    
    //MARK: - Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if editButton.title == "Edit" {
            editButton.title = "Done"
            editMode = true
            newAlbum.title = "Delete Selected Photos"
        } else {
            editButton.title = "Edit"
            editMode = false
            newAlbum.title = "New Album"
            for item in selectedItems {
                if let cell = collectionView.cellForItemAtIndexPath(item) {
                    cell.alpha = 1.0
                    cell.selected = false
                }
            }
            selectedItems = []
        }
    }
    
    @IBAction func newAlbumButtonPressed(sender: AnyObject)  {
        if newAlbum.title == "New Album" {
            allowInteraction(false)
            self.noPhotosLabel.hidden = true
            deleteAllPhotos()
            
            FlickrClient.sharedInstance.getImagesForPin(pin, context: sharedContext, completionHandler: { (error) in
                performUIUpdatesOnMain {
                    if error != nil {
                        self.editButton.enabled = false
                        if error!.code == 1 {
                            self.noPhotosLabel.text = "Error Downloading Photos"
                            self.noPhotosLabel.hidden = false
                        } else if error!.code == 2 {
                            self.noPhotosLabel.text = "No Photos To Show"
                            self.noPhotosLabel.hidden = false
                        }
                        
                    } else {
                        self.editButton.enabled = true
                        CoreDataStack.stack.save()
                        self.collectionView.reloadData()
                    }
                    
                    self.allowInteraction(true)
                }
            })
        } else {
            deletePhotos()
        }
    }
    
    /**
     Sets the flow layout for the collection view cells.
     */
    private func establishFlowLayout() {
        let space: CGFloat = 0
        let width = self.view.frame.width
        let dimensions = width / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimensions, dimensions)
    }
    
    /**
     Allows the user to tap the edit button and new album button.
     
     - Parameter allow: A Bool of whether to allow user interaction.
     */
    private func allowInteraction(allow: Bool) {
        editButton.enabled = allow
        newAlbum.enabled = allow
    }
    
    //MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as? PhotoCell {
            
            cell.configureCell(photo)
            
            return cell
        } else {
            return PhotoCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editMode {
            //Allows user selection
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            if cell.alpha == 1.0 {
                cell.alpha = 0.5
            } else {
                cell.alpha = 1.0
            }
            if cell.alpha == 0.5 {
                selectedItems.append(indexPath)
            } else {
                let index = selectedItems.indexOf(indexPath)!
                selectedItems.removeAtIndex(index)
            }
        } else {
            //If not in edit mode show the user the larger photo
            performSegueWithIdentifier("showPhoto", sender: fetchedResultsController.objectAtIndexPath(indexPath))
        }
    }
    
    //MARK: - MapView
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "userPin"
        
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
        let pin = views[0].annotation?.coordinate
        
        let span = MKCoordinateSpanMake(0.7, 0.7)
        
        let region = MKCoordinateRegionMake(pin!, span)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - Delete
    
    /**
     Deletes the user selected photos from the shared NSManagedObjectContext.
    */
    private func deletePhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedItems {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        
        selectedItems = [NSIndexPath]()
    }
    
    /**
     Deletes all the photos from the shared NSManagedObjectContext.
     */
    private func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        
    }
    
    //MARK: - NSFetchedControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Update:
            updatedIndexPaths.append(indexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Move:
            break
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({ 
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
        CoreDataStack.stack.save()
    }
    
    //MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhoto" {
            if let photoVC = segue.destinationViewController as? PhotoVC {
                photoVC.photo = sender as! Photo
            }
        }
    }

}
