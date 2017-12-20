//
//  ForecastPeriod.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 10.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import Foundation
import CoreData
import Aeris

class ForecastPeriod: NSManagedObject {
    
    static func createOrUpdate(_ awfForecast: AWFForecast, in context: NSManagedObjectContext) throws -> NSSet {
        
        let periods = NSSet()
        for awfPeriod in awfForecast.periods as! [AWFForecastPeriod]{
            let period = ForecastPeriod(context: context)
            period.avgTemp = Float(awfPeriod.avgTempC!)
            period.icon = awfPeriod.icon!
            period.maxTemp = Float(awfPeriod.maxTempC!)
            period.minTemp = Float(awfPeriod.minTempC!)
            period.timestamp = awfPeriod.timestamp! as NSDate
            period.place = try? Place.createOrUpdate(awfForecast.place, in: context)
            periods.adding(period)
        }
        
        return periods
    }
}
