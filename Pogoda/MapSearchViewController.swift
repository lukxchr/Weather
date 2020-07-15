//
//  MapSearchViewController.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit
import MapKit

class MapSearchViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    private var chosenCoords: CLLocationCoordinate2D? {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            latitudeTextField.text = ""
            longitudeTextField.text = ""
            if let coords = chosenCoords {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coords
                mapView.addAnnotation(annotation)
                mapView.showAnnotations(mapView.annotations, animated: true)
                let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                let region = MKCoordinateRegionMake(coords, span)
                mapView.setRegion(region, animated: true)
                getWeatherButton.isEnabled = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //checks if coords in string format are valid and if yes returns coords as 2-tuple of Doubles
    //otherwise returns nil
    private func parseCoords(stringLatitude: String, stringLongitude: String) ->
        (latitude: Double, longitude: Double)? {
            //depending on location the keybord can use "," instead of "." for decimal point
            //Double initilizer from String dosn't work in this case so replace before trying to convert
            if let latitude = Double(stringLatitude.replacingOccurrences(of: ",", with: ".")),
                let longitude = Double(stringLongitude.replacingOccurrences(of: ",", with: ".")) {
                if abs(latitude) > 90 { return nil }
                if abs(longitude) > 180 { return nil }
                return (latitude, longitude)
            }
            return nil
    }
    
    
    
    @IBAction func searchLocation(_ sender: Any) {
        //make sure the keyboards is hidden
        latitudeTextField.resignFirstResponder()
        longitudeTextField.resignFirstResponder()
        
        //try to set chosenCoords, the didSet observer on chosenCoords will update map annotation
        if let (latitude, longitude) = parseCoords(stringLatitude: latitudeTextField.text!, stringLongitude: longitudeTextField.text!) {
            chosenCoords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            chosenCoords = nil
            getWeatherButton.isEnabled = false
            let title = "Failed to find location for given coordinates"
            let message = "Try again or select your location by long tapping on the map"
            presentAlert(title: title, message: message)
        }
    }
    
    @IBAction func longPressedMapView(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        let touchPoint = sender.location(in: self.mapView)
        let coords = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        chosenCoords = coords
    }
    
    @IBAction func getWeather(_ sender: UIButton) {
        let location = Location.coords(latitude: chosenCoords!.latitude, longitude: chosenCoords!.longitude)
        let vc = (self.tabBarController!.viewControllers!.first as! WeatherViewController)
        vc.currentLocation = location
        self.tabBarController!.selectedIndex = 0
    } 
}
