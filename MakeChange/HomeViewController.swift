//
//  HomeViewController.swift
//  doGood
//
//  Created by Polun, Jordan B. (InfoTechServ) on 6/20/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        designTheme()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        designTheme()
    }
    
    private func designTheme() {
        self.navigationController?.navigationBar.barTintColor = self.tabBarController?.tabBar.barTintColor
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = self.tabBarController?.tabBar.barTintColor
    }

}
