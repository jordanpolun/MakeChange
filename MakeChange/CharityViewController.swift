//
//  ViewController.swift
//  doGood
//
//  Created by Polun, Jordan B. (InfoTechServ) on 5/29/19.
//  Copyright © 2019 Polun, Jordan B. All rights reserved.
//

import UIKit
import os.log
import Stripe

class CharityViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var donate_button: UIButton!
    @IBOutlet weak var money_tf: UITextField!
    @IBOutlet weak var donation_alert: UILabel!
    @IBOutlet weak var charity_title: UILabel!
    @IBOutlet weak var mission_label: UILabel!
    @IBOutlet weak var funds_picker: UIPickerView!    
    
    var charity: CharityModel
    
    required init?(coder aDecoder: NSCoder) {
        charity = CharityModel(name: "", mission: "", image_path: "", url: "", category: "")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        funds_picker.delegate = self
        funds_picker.dataSource = self
        
        donation_alert.text = "You've donated $\(charity.money)"
        charity_title.text = charity.name
        mission_label.text = charity.mission
        addPicture(image: charity.getImage())
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let colors = charity.getImage().getColors()
        //let lightest = charity.getImage().getLightestColor()
        designButton(colors: colors!)
        setBackground(colors: colors!)
        designText(label: charity_title, colors: colors!)
        designText(label: mission_label, colors: colors!)
        designText(label: donation_alert, colors: colors!)
        designNavBar(colors: colors!)
        //designTabBar(lightest: lightest)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return charity.funds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return charity.funds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let colors = charity.getImage().getColors()
        let titleData = charity.funds[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: colors!.primary as Any])
        
        return myTitle
    }
    
    @IBAction func onButtonTap()
    {
        performSegue(withIdentifier: "Show Site", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webViewController = segue.destination as? WebViewController {
            webViewController.url = charity.url!
            webViewController.charity = charity
            webViewController.colors = charity.getImage().getColors()!
        }
    }
    
    private func addPicture(image: UIImage) {
        let picture = UIImageView()
        view.addSubview(picture)
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        picture.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picture.image = resizeImage(image: image, newWidth: 240)
        picture.alpha = 0.25
        view.sendSubviewToBack(picture)
    }
    
    private func designNavBar(colors: UIImageColors) {
        self.navigationController!.navigationBar.tintColor = colors.primary
        self.navigationController!.navigationBar.backgroundColor = colors.background
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = colors.background
    }
    
    private func designTabBar(lightest: UIColor) {
        self.tabBarController!.tabBar.barTintColor = lightest
    }
    
    private func setBackground(colors: UIImageColors) {
        view.backgroundColor = colors.background
    }
    
    private func designButton(colors: UIImageColors) {
        donate_button.backgroundColor = colors.primary
        donate_button.setTitleColor(colors.background, for: .normal)
        donate_button.layer.borderWidth = 5
        donate_button.layer.borderColor = colors.secondary.cgColor
        donate_button.layer.cornerRadius = donate_button.frame.height/2
    }
    
    private func designText(label: UILabel, colors: UIImageColors) {
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            .strokeColor : UIColor.black,
            .foregroundColor : colors.primary,
            .strokeWidth : -1.0,
        ]
        
        label.attributedText = NSAttributedString(string: label.text!, attributes: strokeTextAttributes)
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func showDonateAlert() -> String {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to donate $" + money_tf.text! + " to " + charity.name! + "?", preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.charity.addMoney(donation: (self.money_tf.text! as NSString).integerValue)
            self.donation_alert.text = "You've donated $" + String(self.charity.money)
        }))
        
        let note = UIAlertController(title: "Add note below", message: "", preferredStyle: UIAlertController.Style.alert)
        var message = ""
        
        note.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Add your personal message here"
        })
        
        note.addAction(UIAlertAction(title: "Donate", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            if let noteTextField = note.textFields?.first, noteTextField.text != nil {
                message = noteTextField.text!
            }
            self.charity.addMoney(donation: (self.money_tf.text! as NSString).integerValue)
            self.donation_alert.text = "You've donated $\(self.charity.money)"
        }))
        
        alert.addAction(UIAlertAction(title: "Yes, add note", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.present(note, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        if (message != "") {
            return message
        } else {
            return ""
        }
    }
    
    @IBAction func donate_money(_ sender: Any) {
        if ((self.money_tf.text! as NSString).integerValue <= 0) {
            let alertController = UIAlertController(title: "Error",
                                                    message: "You haven't chosen how much money to donate",
                                                    preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
            return
        }
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        self.navigationController!.pushViewController(addCardViewController, animated: true)
    }
}

extension CharityViewController: STPAddCardViewControllerDelegate {
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController,
                               didCreateToken token: STPToken,
                               completion: @escaping STPErrorBlock) {
        StripeClient.shared.completeCharge(with: token, amount: (100*(self.money_tf.text! as NSString).integerValue)) { result in
            switch result {
            // 1
            case .success:
                completion(nil)
                
                let alertController = UIAlertController(title: "Congrats",
                                                        message: "Your payment was successful!",
                                                        preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            // 2
            case .failure(let error):
                completion(error)
            }
        }

    }
}
