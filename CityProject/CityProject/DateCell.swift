//
//  DateCell.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-02.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

protocol DateCellDelegate {
    func didTapSave(date: Date)
}

class DateCell: UITableViewCell {

    @IBOutlet var datePicker: UIDatePicker!
    var delegate: DateCellDelegate?

    @IBAction func editPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Edit" {
            sender.setTitle("Save", for: .normal)
            datePicker.isUserInteractionEnabled = true
        } else {
            delegate?.didTapSave(date: datePicker.date)
            sender.setTitle("Edit", for: .normal)
            datePicker.isUserInteractionEnabled = false
        }	
    }
}
