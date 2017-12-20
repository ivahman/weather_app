//
//  DailyWeatherViewController.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 05.11.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import UIKit
import Aeris

class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var place:Place?
    
    private var periods = [AWFForecastPeriod]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        temperatureLabel.isHidden = true
        dateLabel.isHidden = true
        
        if let plc = place {
            navigationItem.title = plc.name?.localizedCapitalized
            getWeatherForecast()
        }
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell") as! ForecastTableViewCell
        
        cell.forecastPeriod = periods[indexPath.row]
        
        return cell
    }
    
    private func getWeatherForecast() {
        
        guard let place = place else {
            print("place did not set")
            return
        }
        
        if let plc = AWFPlace(latitude: CGFloat(place.latitude), longitude: CGFloat(place.longitude)) {
            let batchLoader = AWFBatchLoader()
            let observationLoader = AWFObservationsLoader()
            let forecastLoader = AWFForecastsLoader()
            
            batchLoader.addLoader(observationLoader, forKey: "observation")
            batchLoader.addLoader(forecastLoader, forKey: "forecast")
            batchLoader.setPlaceForAllLoaders(plc)
            batchLoader.getWithCompletionBlock{ [weak self] (loader, error) in
                if let error = error {
                    print("batch loader request failed \(error)")
                    return
                }
                
                if let observations = loader?.objectsForLoader(withKey: "observation") as? [AWFObservation] {
                    if let observation = observations.first {
                        self?.updateObservationUI(observation)
                    }
                }
                
                if let forecasts = loader?.objectsForLoader(withKey: "forecast") as? [AWFForecast] {
                    if let forecast = forecasts.first {
                        self?.updateForecastUI(forecast)
                    }
                }
            }
        }
    }
    
    private func updateObservationUI(_ observation: AWFObservation) {
        
        spinner.stopAnimating()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        
        dateLabel.text = dateFormatter.string(from: observation.timestamp!)
        dateLabel.isHidden = false
        temperatureLabel.text = "\(observation.tempC!)ºC"
        temperatureLabel.isHidden = false
        conditionImageView.image = UIImage(named: observation.icon!)
    }
    
    private func updateForecastUI(_ forecast:AWFForecast) {
        
        periods = forecast.periods as! [AWFForecastPeriod]
        forecastTableView.reloadData()
    }
}
