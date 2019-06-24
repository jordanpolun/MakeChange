//
//  CharityModel.swift
//  Make Change
//
//  Created by Jordan Polun on 6/21/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit
import Foundation

class CharityModel: NSObject {
    var name: String?
    var mission: String?
    var image_path: String?
    var url: String?
    var category: String?
    var money: Int
    var funds: [String]
    
    override init() {
        self.money = 0
        self.funds = ["(Choose where your money goes)", "General Fund", "Administration"]
    }
    
    init(name: String, mission: String, image_path: String, url: String, category: String) {
        self.name = name
        self.mission = mission
        self.image_path = image_path
        self.url = url
        self.category = category
        self.money = 0
        self.funds = ["(Choose where your money goes)", "General Fund", "Administration"]
    }
    
    func getImage() -> UIImage {
        return UIImage(named: image_path!)!
    }
    
    func addMoney(donation: Int) {
        money += donation
    }
    
    override var description: String {
        return "Name: \(name!), Mission: \(mission!), Image Path: \(image_path!), URL: \(url!), Category: \(category!)"
    }
}
