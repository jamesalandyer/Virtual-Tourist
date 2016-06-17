//
//  Album.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import CoreData


class Album: NSManagedObject {

    convenience init(name: String = "New Album", context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entityForName("Album", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = name
            self.creationDate = NSDate()
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
