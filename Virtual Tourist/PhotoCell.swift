//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/15/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import CoreData

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configureCell(image: Photo) {
        
        guard let newImage = image.imageData else { return }
        
        guard let convertImage = UIImage(data: newImage) else { return }
        
        photoImageView.image = convertImage
        activityIndicator.stopAnimating()
    }
}
