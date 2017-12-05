//
//  PlacesTableViewController.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 05.11.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import UIKit
import Aeris

class FavoritesTableViewController: UITableViewController {

    private var lastAddedPlace: AWFPlace?

    private let storage = ForecastStorage()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return storage.places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)

        cell.textLabel?.text = storage.places[indexPath.row].name

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showForecastForSelectedPlace" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let place: AWFPlace = storage.places[indexPath.row]
                if let forecastVC = segue.destinationVC as? ForecastViewController {
                    configForecastViewController(forecastVC, placeName: place.name!)
                }
            }
        }
        
        if segue.identifier == "showForecastForAddedPlace" {
            if let place = lastAddedPlace {
                if let forecastVC = segue.destinationVC as? ForecastViewController {
                    configForecastViewController(forecastVC, placeName: place.name!)
                }
            }
        }
    }
    
    private func configForecastViewController(_ viewController: ForecastViewController, placeName: String) {
        viewController.observation = storage.getObservation(placeName)
        if let periods = storage.getPeriods(placeName) {
            viewController.periods = periods
        }
    }
    
    @IBAction func addNewPlace(segue: UIStoryboardSegue) {
        
        if let sourceVC = segue.source as? AddPlaceViewController {
            if let selectedPlace = sourceVC.selectedPlace {
                lastAddedPlace = selectedPlace
                storage.places.append(selectedPlace)
                tableView.reloadData()
                getWeatherFor(selectedPlace)
            }
        }
    }
    
    private func getWeatherFor(_ place: AWFPlace) {
        
        let batchLoader = AWFBatchLoader()
        let observationLoader = AWFObservationsLoader()
        let forecastLoader = AWFForecastsLoader()
        
        batchLoader.addLoader(observationLoader, forKey: "observation")
        batchLoader.addLoader(forecastLoader, forKey: "forecast")
        batchLoader.setPlaceForAllLoaders(place)
        batchLoader.getWithCompletionBlock{ [weak self] (loader, error) in
            if let error = error {
                print("batch loader request failed \(error)")
                return
            }
            
            if let observations = loader?.objectsForLoader(withKey: "observation") as? [AWFObservation] {
                if let observation = observations.first {
                    self?.storage.addObservation(observation, for: place.name!)
                }
            }
            
            if let forecasts = loader?.objectsForLoader(withKey: "forecast") as? [AWFForecast] {
                if let forecast = forecasts.first, let periods = forecast.periods as? [AWFForecastPeriod] {
                    self?.storage.addPeriods(periods, for: place.name!)
                }
            }
            
            self?.performSegue(withIdentifier: "showForecastForAddedPlace", sender: nil)
        }
    }
}

extension UIStoryboardSegue {
    
    var destinationVC: UIViewController {
        get {
            if let navigationController = destination as? UINavigationController {
                return navigationController.visibleViewController ?? self.destination
            }
            return self.destination
        }
    }
}
