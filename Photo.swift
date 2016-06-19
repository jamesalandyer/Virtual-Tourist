//
//  Photo.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/18/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    var smallImageURL: String?
    
    convenience init(imageData: NSData?, largeImage: String?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Image", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = imageData
            if largeImage != nil {
                self.largeImageURL = largeImage!
            }
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
