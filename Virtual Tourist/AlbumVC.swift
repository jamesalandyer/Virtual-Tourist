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

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var newAlbum: UIBarButtonItem!
    
    var pin: Pin!
    var editMode = false
    var selectedItems = [NSIndexPath]()
    
    var fetchedResultsController: NSFetchedResultsController!
    var fetchedResultsProcessingOperations: [NSBlockOperation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        establishFlowLayout()
        attemptFetch(fetchedResultsController)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showError), name: "Failed", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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
    
    @IBAction func newAlbumButtonPressed(sender: AnyObject) {
        if newAlbum.title == "New Album" {
            
        } else {
            if selectedItems.count > 0 {
                collectionView.performBatchUpdates({
                    for item in self.selectedItems {
                        print("HERE")
                        let photo = self.fetchedResultsController.objectAtIndexPath(item) as! Photo
                        self.fetchedResultsController.managedObjectContext.deleteObject(photo)
                        self.collectionView.numberOfItemsInSection(0)
                    }
                }, completion: nil)
            }
        }
    }
    
    func establishFlowLayout() {
        let space: CGFloat = 0
        let width = self.view.frame.width
        let dimensions = width / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimensions, dimensions)
    }
    
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
            let cell = collectionView.cellForItemAtIndexPath(indexPath)!
            if cell.alpha == 1.0 {
                cell.alpha = 0.5
            } else {
                cell.alpha = 1.0
            }
            if cell.alpha == 0.5 {
                selectedItems.append(indexPath)
            } else {
                for (index, item) in selectedItems.enumerate() {
                    if item == indexPath {
                        selectedItems.removeAtIndex(index)
                    }
                }
            }
        } else {
            performSegueWithIdentifier("showPhoto", sender: fetchedResultsController.objectAtIndexPath(indexPath))
        }
    }
    
    func showError() {
        print("error")
    }
    
    func deleteCells() {
        collectionView.deleteItemsAtIndexPaths(selectedItems)
        selectedItems = []
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        stack.save()
    }
    
    private func addFetchedResultsProcessingBlock(processingBlock: (Void) -> Void) {
        fetchedResultsProcessingOperations.append(NSBlockOperation(block: processingBlock))
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        fetchedResultsProcessingOperations.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Update:
            addFetchedResultsProcessingBlock { self.collectionView.reloadItemsAtIndexPaths([indexPath!]) }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        if selectedItems.count > 0 {
            deleteCells()
        } else {
            collectionView.performBatchUpdates({ () -> Void in
                for operation in self.fetchedResultsProcessingOperations {
                    operation.start()
                }
                }, completion: nil)
        }
    }
    
    deinit {
        for operation in fetchedResultsProcessingOperations {
            operation.cancel()
        }
        
        fetchedResultsProcessingOperations.removeAll()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhoto" {
            if let photoVC = segue.destinationViewController as? PhotoVC {
                photoVC.photo = sender as! Photo
            }
        }
    }

}
