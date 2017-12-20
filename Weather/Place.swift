//
//  Place.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 10.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import Foundation
import CoreData
import Aeris

class Place: NSManagedObject {
    
    static func createOrUpdate(_ awfPlace: AWFPlace, in context: NSManagedObjectContext) throws -> Place {
        
        let request: NSFetchRequest<Place> = Place.fetchRequest()
        request.predicate = NSPredicate(format: "(latitude == %@) AND (longitude == %@)", awfPlace.latitude, awfPlace.longitude)
        
        do {
            let matches = try context.fetch(request)
            if matches.count == 1 {
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let place = Place(context: context)
        place.name = awfPlace.name!
        place.added = NSDate()
        place.latitude = awfPlace.latitude as Double
        place.longitude = awfPlace.longitude as Double
        
        return place
    }
}
