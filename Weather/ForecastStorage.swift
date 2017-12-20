//
//  ForecastStorage.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 05.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import Foundation

class ForecastStorage {
    
    var places = [Place]()
    
    private var observations = [String: Observation]()
    private var forecastPeriods = [String: [ForecastPeriod]]()
    
    func add(_ observation: Observation, for placeName: String) {
        observations[placeName] = observation
    }
    
    func getObservation(_ placeName: String) -> Observation? {
        return observations[placeName]
    }
    
    func add(_ periods: [ForecastPeriod], for placeName: String) {
        forecastPeriods[placeName] = periods
    }
    
    func getPeriods(_ placeName: String) -> [ForecastPeriod]? {
        return forecastPeriods[placeName]
    }
}
