//
//  AlbumVC.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import CoreData

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        establishFlowLayout()
        attemptFetch(fetchedResultsController)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
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
    
    func showError() {
        
    }

}
