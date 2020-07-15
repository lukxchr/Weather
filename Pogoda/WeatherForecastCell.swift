//
//  WeatherForecastCell.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 28/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit

class WeatherForecastCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var nightTempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    func configure(withWeatherForecastData data: WeatherForecastData) {
        if let date = data.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let dateString = dateFormatter.string(from: date as Date)
            self.dateLabel.text = dateString
        }
        if let cond = data.weatherCondition {
            conditionLabel.text = cond
        }
        if let dayTemp = data.dayTemp {
            self.dayTempLabel.text = "Day: \(dayTemp) °C" //"\(String(format: "%.0f", dayTemp)) °C"
        }
        if let nightTemp = data.nightTemp {
            self.nightTempLabel.text = "Night: \(nightTemp) °C"
        }
    }
    
}
