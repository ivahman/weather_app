//
//  ForecastTableViewCell.swift
//  Weather
//
//  Created by Dmytro Ivakhnenko on 03.12.17.
//  Copyright © 2017 Dmytro Ivakhnenko. All rights reserved.
//

import UIKit
import Aeris

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    var forecastPeriod: AWFForecastPeriod? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        if let forecast = forecastPeriod {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale.current
            dateFormatter.timeZone = forecast.timeZone
            dateLabel.text = dateFormatter.string(from: forecast.timestamp!)
            
            conditionImageView.image = UIImage(named: forecast.icon!)
            
            tempLabel.text = "\(forecast.avgTempC!)ºC"
        }
        
    }
}
