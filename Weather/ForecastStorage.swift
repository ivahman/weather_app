//
//  ForecastStorage.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 05.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import Foundation
import Aeris

class ForecastStorage {
    
    var places = [AWFPlace]()
    
    private var observations = [String: AWFObservation]()
    private var forecastPeriods = [String: [AWFForecastPeriod]]()
    
    func addObservation(_ observation: AWFObservation, for placeName: String) {
        observations[placeName] = observation
    }
    
    func getObservation(_ placeName: String) -> AWFObservation? {
        return observations[placeName]
    }
    
    func addPeriods(_ periods: [AWFForecastPeriod], for placeName: String) {
        forecastPeriods[placeName] = periods
    }
    
    func getPeriods(_ placeName: String) -> [AWFForecastPeriod]? {
        return forecastPeriods[placeName]
    }
}
