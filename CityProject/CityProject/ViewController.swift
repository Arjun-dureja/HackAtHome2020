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
    var annotations = [CityAnnotation]()
    var annotationData = [AnnotationData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Land Mark"
        mapView.layer.cornerRadius = 10
        
        let urlString = "https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            }
        }
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "Cities") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                annotationData = try jsonDecoder.decode([AnnotationData].self, from: savedData)
            } catch {
                print("failed")
            }
        }
        
        for annotation in annotationData {
            let newAnnotation = CityAnnotation(title: annotation.title, coordinate: CLLocationCoordinate2D(latitude: annotation.latitude , longitude: annotation.longitude))
            mapView.addAnnotation(newAnnotation)
            annotations.append(newAnnotation)
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
                if city.name == self.city! || self.city! == "New York" {
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
            
            let annotation = CityAnnotation(title: self.city!, coordinate: CLLocationCoordinate2DMake(latitude, longitude))
            self.annotationData.append(AnnotationData(title: annotation.title!, latitude: Double(annotation.coordinate.latitude), longitude: Double(annotation.coordinate.longitude)))
            self.annotations.append(annotation)
            self.presentAC(city: self.city!, latitude: latitude, longitude: longitude, annotation: annotation)
        }
        self.view.isUserInteractionEnabled = true
    }
    
    func presentAC(city: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, annotation: CityAnnotation) {
        let ac = UIAlertController(title: "Add City", message: "Would you like to add \(city) to your list?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler:  {
            [weak self] _ in
            self?.mapView.addAnnotation(annotation)
            self?.save()
            
            guard let vc = self?.navigationController?.storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else { return }
            
            vc.city = city
            vc.latitude = latitude
            vc.longitude = longitude
            
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }))
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        present(ac, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Error", message: "City does not exist!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CityAnnotation else { return nil}
        
        let identifier = "City"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        
        if let markerView = annotationView as? MKMarkerAnnotationView {
            markerView.tintColor = .systemPink
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let city = view.annotation as? CityAnnotation else { return }
        
        let ac = UIAlertController(title: city.title, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Details", style: .default, handler: {
            [weak self] _ in
            guard let vc = self?.storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController else { return }
            vc.city = city.title
            vc.latitude = city.coordinate.latitude
            vc.longitude = city.coordinate.longitude
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            [weak self] _ in
            let count = self?.annotations.count
            for i in 0..<count! {
                if self?.annotations[i].title == city.title {
                    self?.mapView.removeAnnotation(city)
                    self?.annotations.remove(at: i)
                    self?.annotationData.remove(at: i)
                    self?.save()
                    break
                }
            }
        }))
        ac.addAction((UIAlertAction(title: "Cancel", style: .cancel)))
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(annotationData) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "Cities")
        } else {
            print("Failed to save")
        }
    }
}



