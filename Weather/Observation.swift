//
//  Observation.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 10.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import Foundation
import CoreData
import Aeris

class Observation: NSManagedObject {
    
    static func createOrUpdate(_ awfObservation: AWFObservation, in context: NSManagedObjectContext) throws -> Observation {
        
        let observation = Observation(context: context)
        observation.icon = awfObservation.icon!
        observation.temp = Float(awfObservation.tempC!)
        observation.timestamp = awfObservation.timestamp! as NSDate
        observation.place = try? Place.createOrUpdate(awfObservation.place, in: context)
        
        return observation
    }
}
