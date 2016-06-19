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
    
    convenience init(imageData: NSData?, smallImage: String, largeImage: String?, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = imageData
            self.smallImageURL = smallImage
            if largeImage != nil {
                self.largeImageURL = largeImage!
            }
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
