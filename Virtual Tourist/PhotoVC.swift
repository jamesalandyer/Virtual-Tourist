//
//  PhotoVC.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {

    //Outlets
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var failedLabel: UILabel!
    
    //Properties
    var photo: Photo!
    
    //MARK: - Stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        failedLabel.hidden = true
        activityIndicator.startAnimating()
        
        if let imageURL = photo.largeImageURL {
            FlickrClient.sharedInstance.taskForGETImage(imageURL) { (imageData, error) in
                
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    
                    guard error == nil else {
                        self.failedLabel.hidden = false
                        return
                    }
                    
                    guard let imageData = imageData else {
                        self.failedLabel.hidden = false
                        return
                    }
                    
                    let convertImage = UIImage(data: imageData)
                        
                    self.photoImageView.image = convertImage
                }
                
            }
        }
        
    }

}
