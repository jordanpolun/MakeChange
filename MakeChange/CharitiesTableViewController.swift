//
//  CharitiesTableViewController.swift
//  doGood
//
//  Created by Jordan Polun on 5/31/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit

class CharitiesTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var charitySelected = 0
    var filteredTableData = [Charity]()
    var resultSearchController = UISearchController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Charities"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSearchController = initializeSearch()
        
        tableView.reloadData()
        
        self.designNavBar()
        self.designTabBar()
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        designNavBar()
        designTabBar()
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.isActive) {
            return filteredTableData.count
        }
        return appDelegate.charities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Charity Cell", for: indexPath)
        cell.textLabel?.text = appDelegate.charities[indexPath.row].getName()
        cell.imageView!.image = resizeImage(image: appDelegate.charities[indexPath.row].getImage(), newWidth: 60)
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row].getName()
            cell.imageView!.image = resizeImage(image: filteredTableData[indexPath.row].getImage(), newWidth: 60)
        }
        
        cell.imageView!.layer.cornerRadius = (cell.imageView!.image!.size.width) / 2
        cell.imageView!.clipsToBounds = true
        
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let charity = appDelegate.charities[indexPath.row]
        let alert = UIAlertController(title: "Mission Statement", message: charity.getMission(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Learn More", style: .default, handler:
            { action in
                self.charitySelected = indexPath.row
                self.performSegue(withIdentifier: "Show Charity", sender: nil)
            }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        charitySelected = indexPath.row
        performSegue(withIdentifier: "Show Charity", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Show Charity") {
            let viewController: CharityViewController = segue.destination as! CharityViewController
            /*if (resultSearchController.isActive) {
                viewController.charity = filteredTableData[charitySelected]
            } else {
                viewController.charity = appDelegate.charities[charitySelected]
            }*/
            resultSearchController.isActive = false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTerm = searchController.searchBar.text!.lowercased()
        let array = appDelegate.charities.filter {
            result in return (result.getName().lowercased().contains(searchTerm) || result.getCategory().lowercased().contains(searchTerm))
        }
        filteredTableData = array
        
        self.tableView.reloadData()
    }
    
    private func initializeSearch() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        
        controller.searchBar.barTintColor = view.backgroundColor
        controller.searchBar.layer.borderWidth = 1;
        controller.searchBar.layer.borderColor = view.backgroundColor?.cgColor
    
        tableView.tableHeaderView = controller.searchBar
    
        return controller
    }
    
    private func designNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.backgroundColor = view.backgroundColor
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = view.backgroundColor
    }
    
    private func designTabBar() {
        self.tabBarController!.tabBar.barTintColor = view.backgroundColor
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
