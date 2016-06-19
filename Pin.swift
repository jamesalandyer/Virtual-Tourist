//
//  Pin.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/18/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double)
    }
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = NSNumber(double: latitude)
            self.longitude = NSNumber(double: longitude)
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
