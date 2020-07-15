//
//  WeatherViewController.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //currentLocation is set from other view controller
    //once set current weather and weather forecast are fetched and 
    //stored in weatherData/weatherDorecastData which in turn are
    //used to populate tableView
    var currentLocation: Location? {
        didSet {
            fetchWeatherAndForecastForCurrentLocation()
        }
    }
    private var weatherData: WeatherData? {
        didSet {
            tableView.reloadData()
        }
    }
    private var weatherForecastData = [WeatherForecastData]() {
        didSet {
            tableView.reloadData()
        }
    }

    //MARK: Outlets and VC lifecycle methods
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocation()
        //get new wether data when every time the app enters foreground
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.fetchWeatherAndForecastForCurrentLocation), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //this is executed only when the app is launched for the first time
        if currentLocation == nil {
            let message = "Use search location or map tab to set your location"
            presentAlert(title: "Choose your location", message: message)
        }
    }
    
    //MARK: table view delegate and data source methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = indexPath.section == 0 ? "currentWeatherCell" : "weatherForecastCell"
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CurrentWeatherCell
            if let data = weatherData {
                cell.configure(withWeatherData: data)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! WeatherForecastCell
            if  weatherForecastData.count == 6 {
                cell.configure(withWeatherForecastData: weatherForecastData[indexPath.row])
            }
            return cell
            }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return weatherData != nil ? 2 : 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 150 : 75
    }
    
    //MARK: methods for fetching the data from the model
    
    @objc private func fetchWeatherAndForecastForCurrentLocation() {
        if currentLocation == nil { return }
        //get current data and store it weatherData if successful
        //otherwise show error message
        getCurrentWeatherData(forLocation: currentLocation!,
            completionHandler: {success, data in
                DispatchQueue.main.async {
                if !success {
                    var message: String
                    switch self.currentLocation! {
                    case .zipCode:
                        //custom error message if the user is searching by zip code because OpenWeather
                        //is not reliable for this method
                        message = "Failed to fetch current weather. Try selecting your location by city name or on the map, rather than by zip code."
                    default:
                        message = "Failed to fetch current weather. Please check your internet connection or try different location."
                    }
                    self.presentAlert(title: "Error", message: message)
                    
                } else {
                    self.weatherData = data
                    self.storeLocation()
                }
                }
        })
        //get weather forecast and store it weatherForecastData if successful
        //otherwise show error message
        let nDays = 6 //1 + num days to fetch forecast for (first result is weather for current date)
        getWeatherForecast(forLocation: currentLocation!, forNumDays: nDays, completionHandler: {
            success, data in
                if !success {
                    return
                } else {
                    self.weatherForecastData.removeAll()
                    self.weatherForecastData = data!
            }
        })
    }
    
    //MARK: methods for storing/loading location in/from UserDeafults
    
    private func storeLocation() {
        if currentLocation == nil { return }
        let defaults = UserDefaults.standard
        //clean up
        defaults.removeObject(forKey: "cityLocation")
        defaults.removeObject(forKey: "zipCodeLocation")
        defaults.removeObject(forKey: "latitude")
        defaults.removeObject(forKey: "longitude")
        //save associated value in UserDefaults
        switch currentLocation! {
        case .cityName(let name):
            defaults.set(name, forKey: "stringLocation")
        case .zipCode(let zipCode):
            defaults.set(zipCode, forKey: "zipCodeLocation")
        case .coords(let latitude, let longitude):
            defaults.set(latitude, forKey: "latitude")
            defaults.set(longitude, forKey: "longitude")
        }
    
    }
    
    private func loadLocation() {
        let defaults = UserDefaults.standard
        if let cityLocation = defaults.string(forKey: "cityLocation") {
            currentLocation = .cityName(name: cityLocation)
            return
        }
        if let zipCodeLocation = defaults.string(forKey: "zipCodeLocation") {
            currentLocation = .zipCode(zipCode: zipCodeLocation)
            return
        }
        //use object:forKey and then cast to Dobule because
        //double:forKey returns 0 if object not found
        //which would lead to ambiguity in this case
        if let latitude = defaults.object(forKey: "latitude"),
            let longitude = defaults.object(forKey: "longitude") {
            if let doubleLat = latitude as? Double, let doubleLon = longitude as? Double {
                currentLocation = .coords(latitude: doubleLat, longitude: doubleLon)
            }
        }
    }
}


