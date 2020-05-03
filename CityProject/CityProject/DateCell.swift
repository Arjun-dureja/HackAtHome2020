//
//  DateCell.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class DateCell: UITableViewCell {

    @IBOutlet var datePicker: UIDatePicker!

    @IBAction func editPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Edit" {
            sender.setTitle("Save", for: .normal)
            datePicker.isUserInteractionEnabled = true
        } else {
            sender.setTitle("Edit", for: .normal)
            datePicker.isUserInteractionEnabled = false
        }	
    }
}
