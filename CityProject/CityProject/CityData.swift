//
//  CityData.swift
//  CityProject
//
//  Created by Arjun Dureja on 2020-05-03.
//  Copyright © 2020 Arjun Dureja. All rights reserved.
//

import UIKit

class CityData: NSObject, Codable {
    var title: String
    var date: Date
    var picture: String
    var comments: String
    
    init(title: String, date: Date, picture: String, comments: String) {
        self.title = title
        self.date = date
        self.picture = picture
        self.comments = comments
    }
}
