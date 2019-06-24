//
//  ListViewController.swift
//  Make Change
//
//  Created by Jordan Polun on 6/21/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, HomeModelProtocol {

    var feedItems: NSArray = NSArray()
    var selectedCharity : Int = 0
    var filteredTableData = [CharityModel]()
    var resultSearchController = UISearchController()
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
        resultSearchController = initializeSearch()
        
        self.listTableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        designNavBar()
        designTabBar()
        designTable()
        if let index = self.listTableView.indexPathForSelectedRow{
            self.listTableView.deselectRow(at: index, animated: true)
        }
    }
    
    func itemsDownloaded(items: NSArray) {
        feedItems = items.sorted(by: {($0 as! CharityModel).name!.lowercased() < ($1 as! CharityModel).name!.lowercased()}) as NSArray
        self.listTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.isActive) {
            return filteredTableData.count
        }
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "BasicCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        
        let item: CharityModel = feedItems[indexPath.row] as! CharityModel
        
        cell.textLabel!.text = item.name
        cell.backgroundColor = view.backgroundColor
        cell.accessoryType = .detailDisclosureButton
        
        cell.imageView!.image = resizeImage(image: item.getImage(), newWidth: 60)
        cell.imageView!.layer.cornerRadius = (cell.imageView!.image!.size.width) / 2
        cell.imageView!.clipsToBounds = true
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row].name
            cell.imageView!.image = resizeImage(image: filteredTableData[indexPath.row].getImage(), newWidth: 60)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        var charity = self.feedItems[indexPath.row] as! CharityModel
        if (resultSearchController.isActive) {
            charity = self.filteredTableData[indexPath.row]
        }
        let alert = UIAlertController(title: "Mission Statement", message: charity.mission, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Learn More", style: .default, handler:
            { action in
                self.selectedCharity = indexPath.row
                self.performSegue(withIdentifier: "Show Charity", sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCharity = indexPath.row
        performSegue(withIdentifier: "Show Charity", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Show Charity") {
            let viewController: CharityViewController = segue.destination as! CharityViewController
            
            if (resultSearchController.isActive) {
                viewController.charity = filteredTableData[selectedCharity]
            } else {
            viewController.charity = self.feedItems[selectedCharity] as! CharityModel
            }
            resultSearchController.isActive = false
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchTerm = searchController.searchBar.text!.lowercased()
        let array = feedItems.filter {
            result in return ((result as! CharityModel).name!.lowercased().contains(searchTerm) || (result as! CharityModel).category!.lowercased().contains(searchTerm))
        }
        filteredTableData = array as! [CharityModel]
        
        self.listTableView.reloadData()
    }
    
    private func initializeSearch() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        
        controller.searchBar.barTintColor = view.backgroundColor
        controller.searchBar.layer.borderWidth = 1;
        controller.searchBar.layer.borderColor = view.backgroundColor?.cgColor
        
        listTableView.tableHeaderView = controller.searchBar
        
        return controller
    }
    
    private func designTable() {
        self.listTableView.backgroundColor = view.backgroundColor
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
