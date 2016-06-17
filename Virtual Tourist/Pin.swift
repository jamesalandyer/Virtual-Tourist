//
//  Pin.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation
import MapKit
import CoreData


class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    func convertToMapPin(pin: Pin) -> MKPointAnnotation {
        let newPin = MKPointAnnotation()
        
        newPin.coordinate.latitude = Double(pin.latitude!)
        newPin.coordinate.longitude = Double(pin.longitude!)
        
        return newPin
    }

}
