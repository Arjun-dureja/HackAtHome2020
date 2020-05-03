//
//  DetailViewController.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import MapKit
import UIKit

class DetailViewController: UITableViewController {
    var city: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let city = city {
            title = city
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel(frame: CGRect(x: 15, y: 7, width: 200, height: 35))
        
        label.font = UIFont.boldSystemFont(ofSize: 18)

        view.backgroundColor = .systemPink
        
        if section == 0 {
            label.text = "Location"
        }
        else if section == 1 {
            label.text = "Date Visited"
        }
        else if section == 2 {
            label.text = "Picture"
        }
        
        view.addSubview(label)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Location", for: indexPath) as? LocationCell else {
                fatalError("Unable to dequeue cell")
            }
            let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            cell.mapView.setRegion(region, animated: false)
            
            cell.mapView.layer.cornerRadius = 10
            cell.mapView.isUserInteractionEnabled = false
            
            let annotation = MKPointAnnotation()
            annotation.title = city
            annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            cell.mapView.addAnnotation(annotation)
            
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Date", for: indexPath) as? DateCell else {
                fatalError("Unable to dequeue cell")
            }
            cell.datePicker.maximumDate = Date()
            cell.datePicker.isUserInteractionEnabled = false
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as? PictureCell else {
                fatalError("Unable to dequeue cell")
            }
            return cell
        }
    }
}
