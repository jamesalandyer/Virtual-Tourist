//
//  Image.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import CoreData


class Image: NSManagedObject {

    convenience init(imageData: NSData, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Image", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = imageData
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
