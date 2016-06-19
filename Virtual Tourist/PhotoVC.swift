//
//  PhotoVC.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageURL = photo.largeImageURL {
            FlickrClient.sharedInstance.taskForGETImage(imageURL) { (imageData, error) in
                
                guard error == nil else {
                    //TODO: Error
                    return
                }
                
                guard let imageData = imageData else {
                    //TODO: Error
                    return
                }
                
                performUIUpdatesOnMain {
                    let convertImage = UIImage(data: imageData)
                    
                    self.photoImageView.image = convertImage
                    self.activityIndicator.stopAnimating()
                }
                
            }
        }
        
    }

}
