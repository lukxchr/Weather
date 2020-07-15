//
//  SearchLocationViewController.swift
//  Pogoda
//
//  Created by Lukasz Chrzanowski on 22/01/2017.
//  Copyright © 2017 LC. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationViewController: UIViewController, UISearchResultsUpdating, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var resultSearchController: UISearchController!
    
    let completer = MKLocalSearchCompleter()
    var completerResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        completer.delegate = self
        self.resultSearchController.searchBar.placeholder = "Search for city or zip code"
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resultSearchController.isActive = false
        self.completerResults.removeAll()
        self.tableView.reloadData()
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        self.tableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        completer.queryFragment = resultSearchController.searchBar.text ?? ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 && completerResults.count != 0 ? "Suggested Locations:" : nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let searchStringEmpty = resultSearchController.searchBar.text! == ""
        return section == 1 ? completerResults.count : (searchStringEmpty ? 0 : 2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 1 {
            cell.textLabel?.text = completerResults[indexPath.row].title
        } else if indexPath.section == 0 {
            let text = "Treat '\(resultSearchController.searchBar.text!)' as " +
                (indexPath.row == 0 ? "city" : "zip code")
            cell.textLabel?.text = text
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let phrase = resultSearchController.searchBar.text!
            var location: Location
            if indexPath.row == 0 {
                location = Location.cityName(name: phrase)
            } else {
                location = Location.zipCode(zipCode: phrase)
            }
            self.resultSearchController.isActive = false
            let vc = (self.tabBarController!.viewControllers!.first as! WeatherViewController)
            vc.currentLocation = location
            self.tabBarController!.selectedIndex = 0
            
        } else {
            //if user chooses one of MapKit suggestions retrive its coordinates
            //and use them to represent chosen location
            let completion = completerResults[indexPath.row]
            let request = MKLocalSearchRequest(completion: completion)
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: { reponse, _ in
                if let mapItem = reponse?.mapItems.first {
                    let coords = mapItem.placemark.coordinate
                    let latitude = coords.latitude
                    let longitude = coords.longitude
                    let location = Location.coords(latitude: latitude, longitude: longitude)
                    self.resultSearchController.isActive = false
                    let vc = (self.tabBarController!.viewControllers!.first as! WeatherViewController)
                    vc.currentLocation = location
                    self.tabBarController!.selectedIndex = 0
                }
            })
        }
    }
}
