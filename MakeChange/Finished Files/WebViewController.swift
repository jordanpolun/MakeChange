//
//  WebViewController.swift
//  doGood
//
//  Created by Jordan Polun on 6/1/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit
import WebKit
import os.log

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var url: String = "https://www.apple.com"
    var colors = UIImageColors(background: UIColor(), primary: UIColor(), secondary: UIColor(), detail: UIColor())
    @IBOutlet var swipeBack: UIScreenEdgePanGestureRecognizer!
    @IBOutlet var webView: WKWebView!
    var charity: CharityModel? = nil
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let site = URL(string: url)
        let request = URLRequest(url: site!)
        webView.load(request)
        swipeBack.edges = .left
        view.addGestureRecognizer(swipeBack)
        designNavBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Show Charity") {
            let viewController: CharityViewController = segue.destination as! CharityViewController
            viewController.charity = charity!
        }
    }
    
    @IBAction func back(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: "Show Charity", sender: nil)
        }
    }
    
    private func designNavBar() {
        self.navigationController!.navigationBar.tintColor = colors.primary
        self.navigationController!.navigationBar.backgroundColor = colors.background
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = colors.background
    }
}
