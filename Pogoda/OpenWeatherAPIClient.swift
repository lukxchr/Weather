//
//  OpenWeatherAPIClient.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//


import Alamofire
import SwiftyJSON

private let APIcurrentWeatherEndPoint = "http://api.openweathermap.org/data/2.5/weather"
private let APIweatherForecastEndPoint = "http://api.openweathermap.org/data/2.5/forecast/daily"
private let APIkey = "fill out with api key"

private func getCurrentWeatherData(withURL url: String, parameters: [String:Any], completionHandler: @escaping (Bool, WeatherData?) -> ()) {
    Alamofire.request(url, parameters : parameters).response(completionHandler:  { response in
        let JSONdata = JSON(response.data as Any)
        let code = JSONdata["cod"].int
        if code != 200 {
            completionHandler(false, nil)
        } else {
            let locationDescription = (JSONdata["name"].string ?? "") + ", " + (JSONdata["sys"]["country"].string ?? "")
            let condition = JSONdata["weather"].array?[0]["description"].string
            let temperature = JSONdata["main"]["temp"].double
            let rain = JSONdata["rain"]["3h"].double
            let snow = JSONdata["snow"]["3h"].double
            let cloudiness = JSONdata["clouds"]["all"].double
            let wind_speed = JSONdata["wind"]["speed"].double
            let pressure = JSONdata["main"]["pressure"].double
            let weatherData = WeatherData(locationDescription: locationDescription, weatherCondition: condition, temperature: temperature, rain: rain, snow: snow, cloudiness: cloudiness, wind_speed: wind_speed, pressure: pressure)
            completionHandler(true, weatherData)
        }
    })
}

func getCurrentWeatherData(forLocation location: Location,
        completionHandler: @escaping (Bool, WeatherData?) -> ()) {
    var params = [String:Any]()
    params["APPID"] = APIkey
    params["units"] = "metric"
    switch location {
    case let .cityName(name):
        params["q"] = name
    case let .zipCode(zipCode):
        params["zip"] = zipCode
    case let .coords(latitude, longitude):
        params["lat"] = latitude
        params["lon"] = longitude
    }
    getCurrentWeatherData(withURL: APIcurrentWeatherEndPoint, parameters: params,
        completionHandler: { success, data in
            if !success {
                completionHandler(false, nil)
            } else {
                completionHandler(true, data)
            }
    })
}

func getWeatherForecast(forLocation location: Location, forNumDays
    days: Int, completionHandler: @escaping (Bool, [WeatherForecastData]?) -> ()) {
    var params = [String:Any]()
    params["APPID"] = APIkey
    params["units"] = "metric"
    params["cnt"] = days
    switch location {
    case let .cityName(name):
        params["q"] = name
    case let .zipCode(zipCode):
        params["zip"] = zipCode
    case let .coords(latitude, longitude):
        params["lat"] = latitude
        params["lon"] = longitude
    }
    Alamofire.request(APIweatherForecastEndPoint, parameters: params).response(completionHandler : { response in
        let JSONdata = JSON(response.data as Any)
        let code = JSONdata["cod"]
        if code != "200" {
            completionHandler(false, nil)
        } else {
            var res = [WeatherForecastData]()
            for (_, forecast):(String, JSON) in JSONdata["list"] {
                let timestamp = forecast["dt"].double! as TimeInterval
                let date = NSDate(timeIntervalSince1970: timestamp)
                let dayTemp = forecast["temp"]["day"].int
                let nightTemp = forecast["temp"]["night"].int
                let weatherCondition = forecast["weather"].array?[0]["description"].string
                let data = WeatherForecastData(date: date, dayTemp: dayTemp, nightTemp: nightTemp, weatherCondition: weatherCondition)
                res.append(data)
            }
            completionHandler(true, res)
        }
    })
}


