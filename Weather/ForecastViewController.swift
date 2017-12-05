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
    
    var observation: AWFObservation?
    var periods = [AWFForecastPeriod]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        
        updateUI()
    }
    
    private func updateUI() {
        
        if let obs = observation {
            navigationItem.title = obs.place.formattedNameFull.localizedCapitalized
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            
            dateLabel.text = dateFormatter.string(from: obs.timestamp!)
            temperatureLabel.text = "\(obs.tempC!)ºC"
            conditionImageView.image = UIImage(named: obs.icon!)
        }
        
        forecastTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell") as! ForecastTableViewCell
        
        cell.forecastPeriod = periods[indexPath.row]
        
        return cell
        
    }
}
