//
//  CurrentWeatherCell.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit

class CurrentWeatherCell: UITableViewCell {
    
    
    @IBOutlet weak var chosenLocationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    func configure(withWeatherData weatherData: WeatherData) {
        if let loc = weatherData.locationDescription {
            self.chosenLocationLabel.text = loc
        } else {
            self.chosenLocationLabel.text = "–"
        }
        if let temp = weatherData.temperature {
            self.temperatureLabel.text = "\(String(format: "%.0f", temp)) °C"
        } else {
            self.temperatureLabel.text = "–"
        }
        if let cond = weatherData.weatherCondition {
            self.conditionLabel.text = cond
        } else {
            self.conditionLabel.text = "-"
        }
        if let cloud = weatherData.cloudiness {
            self.cloudLabel.text = "Cloudiness: \(String(format: "%.0f", cloud))%"
        } else {
            self.cloudLabel.text = "-"
        }
        if let wind = weatherData.wind_speed {
            self.windLabel.text = "Wind: \(String(format: "%.1f", wind)) mps"
        } else {
            self.windLabel.text = "–"
        }
        if let pressure = weatherData.pressure {
            self.pressureLabel.text = "Pressure: \(String(format: "%.1f", pressure)) hPa"
        } else {
            self.pressureLabel.text = "–"
        }
    }
}
