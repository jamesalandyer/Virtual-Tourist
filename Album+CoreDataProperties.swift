//
//  Album+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/17/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Album {

    @NSManaged var creationDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var images: NSSet?
    @NSManaged var pin: Pin?

}
