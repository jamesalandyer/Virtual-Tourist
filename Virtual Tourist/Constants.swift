//
//  Constants.swift
//  Virtual Tourist
//
//  Created by James Dyer on 6/16/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import CoreData

let purpleColor = UIColor(red: 103.0 / 255.0, green: 63.0 / 255.0, blue: 180.0 / 255.0, alpha: 1)

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}