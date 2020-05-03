//
//  DetailViewController.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import MapKit
import UIKit

class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var city: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var picture: UIImage = UIImage.actions
    var date: Date!
    var comments: String!
    var cityData = [CityData]()
    var currentCityIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let city = city {
            title = city
        }
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "Data") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                cityData = try jsonDecoder.decode([CityData].self, from: savedData)
            } catch {
                print("Failed")
            }
        }
    
        for i in 0..<cityData.count {
            if cityData[i].title == self.title {
                currentCityIndex = i
                return
            }
        }
        
        let newCity = CityData(title: self.title!, date: Date(), picture: "", comments: "")
        cityData.append(newCity)
        currentCityIndex = cityData.count - 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 250
        }
        return 200
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
        else if section == 3 {
            label.text = "Comments"
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
            
            cell.delegate = self
            cell.datePicker.date = cityData[currentCityIndex].date
            cell.datePicker.maximumDate = Date()
            cell.datePicker.isUserInteractionEnabled = false
            
            return cell
        }
        else if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as? PictureCell else {
                fatalError("Unable to dequeue cell")
            }
            
            let path = getDocumentsDirectory().appendingPathComponent(cityData[currentCityIndex].picture)
            cell.picture.image = UIImage(contentsOfFile: path.path)
            
            cell.picture.layer.borderColor = UIColor.lightGray.cgColor
            cell.picture.layer.borderWidth = 2
            cell.picture.layer.cornerRadius = 10
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Comments", for: indexPath) as? CommentsCell else {
                fatalError("Unable to dequeue cell")
            }
            cell.delegate = self
            cell.comments.text = cityData[currentCityIndex].comments
            cell.comments.layer.borderColor = UIColor.lightGray.cgColor
            cell.comments.layer.borderWidth = 2
            cell.comments.layer.cornerRadius = 10
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        cityData[currentCityIndex].picture = imageName
        save()
        
        dismiss(animated: true)
        tableView.reloadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(cityData) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "Data")
        } else {
            print("Failed to save")
        }
    }
}

extension DetailViewController: DateCellDelegate {
    func didTapSave(date: Date) {
        self.date = date
        self.cityData[currentCityIndex].date = date
        self.save()
    }
}

extension DetailViewController: CommentsCellDelegate {
    func didTapSave(comment: String?) {
        if let comment = comment {
            self.comments = comment
            self.cityData[currentCityIndex].comments = comment
            self.view.endEditing(true)
            self.save()
        }
    }
}
