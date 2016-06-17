//
//  Image+CoreDataProperties.swift
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

extension Image {

    @NSManaged var imageData: NSData?
    @NSManaged var album: Album?

}
