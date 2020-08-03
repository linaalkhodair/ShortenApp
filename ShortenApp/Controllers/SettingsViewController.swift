//
//  SettingsViewController.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 23/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import UIKit
import Toast_Swift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var apiKeyField: UITextField!
    @IBOutlet weak var domainField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        let api = UserDefaults.standard.string(forKey: "apiKey") ?? "Not set"
        
        if (api != "Not set") {
            apiKeyField.text = UserDefaults.standard.string(forKey: "apiKey")
            domainField.text = UserDefaults.standard.string(forKey: "domain")
        }
        
    } //end viewDidLoad
    
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        
        let apiKey = apiKeyField.text
        var domain = domainField.text
        
        if (apiKey!.isEmpty) {
            Alert.showBasicAlert(on: self, with: "Something went wrng!", message: "Please fill in API Key field and try again.")
        } else {
            if (domain!.isEmpty){
                domain = "short.fyi"
            }
            saveUserCredentials(apiKey: apiKey!, domain: domain!)
        }
        
    }
    
    //function that adds user's domain, api key to UserDefaults to save them across all app
    func saveUserCredentials(apiKey: String, domain: String) {
        
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(domain, forKey: "domain")
        DispatchQueue.main.async {
            self.view.makeToast("Settings saved successfully.")
        }
        
        
    }// end saveUserCredentials
    
} // end SettingsViewController
