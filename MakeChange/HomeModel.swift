//
//  HomeModel.swift
//  Make Change
//
//  Created by Jordan Polun on 6/21/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit
import Foundation

protocol HomeModelProtocol: class {
    func itemsDownloaded(items: NSArray)
}

class HomeModel: NSObject, URLSessionDataDelegate {
    weak var delegate: HomeModelProtocol!
    var data = Data()
    let urlPath: String = "http://makechange.site/service.php"
    
    func downloadItems() {
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task  = defaultSession.dataTask(with: url) { (data, response, error)
            in
            if error != nil {
                print("Failed to download data")
            } else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data:Data) {
        var jsonResult = NSArray()
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        var jsonElement = NSDictionary()
        let charities = NSMutableArray()
        
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let charity = CharityModel()
            
            if let name = jsonElement["Name"] as? String,
            let mission = jsonElement["Mission"] as? String,
            let image_path = jsonElement["ImagePath"] as? String,
            let url = jsonElement["URL"] as? String,
            let category = jsonElement["Category"] as? String {
                charity.name = name
                charity.mission = mission
                charity.image_path = image_path
                charity.url = url
                charity.category = category
            }
            charities.add(charity)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: charities)
        })
    }
}
