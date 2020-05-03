//
//  ViewController.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var city: String?
    var cities = [City]()
    var annotations = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Visited Cities"
        mapView.layer.cornerRadius = 10
        
        let urlString = "https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonCities = try? decoder.decode([City].self, from: json) {
            cities = jsonCities
        }
    }

    @IBAction func searchButtonClicked(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.isUserInteractionEnabled = false
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            guard let response = response else {
                self.showError()
                return
            }
            
            var exists = false
            
            for item in response.mapItems {
                self.city = item.placemark.name!
            }
            
            for city in self.cities {
                if city.name == self.city || self.city == "New York" {
                    exists = true
                    break
                }
            }
            
            if exists == false {
                self.showError()
                return
            }
            
            let latitude = response.boundingRegion.center.latitude
            let longitude = response.boundingRegion.center.longitude
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            for annotation in self.annotations {
                if latitude == annotation.coordinate.latitude && longitude == annotation.coordinate.longitude {
                    return
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = self.city
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            self.annotations.append(annotation)
            self.presentAC(city: self.city!, latitude: latitude, longitude: longitude, annotation: annotation)
        }
        self.view.isUserInteractionEnabled = true
    }
    
    func presentAC(city: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, annotation: MKPointAnnotation) {
        let ac = UIAlertController(title: "Add City", message: "Would you like to add \(city) to your list?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler:  {
            [weak self] _ in
            self?.mapView.addAnnotation(annotation)
            
            guard let vc = self?.navigationController?.storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else { return }
            vc.city = city
            vc.latitude = latitude
            vc.longitude = longitude
            
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Error", message: "City does not exist!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
    }
}


