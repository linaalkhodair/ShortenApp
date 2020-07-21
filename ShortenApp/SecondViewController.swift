//
//  SecondViewController.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 12/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class SecondViewController: UIViewController {

    @IBOutlet weak var shortField: UITextField!
    @IBOutlet weak var destinationUrl: UITextField!
    @IBOutlet weak var domain: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchBtnTapped(_ sender: Any) {
        //check not empty!
        if (shortField.text == "") {
            Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "Missing short URL field, please try again.")
        } else {
            
            let aliasName = getAliasName(shortUrl: shortField.text!)
            getAlias(aliasName: aliasName)
        }
    }
    
    func getAliasName(shortUrl: String) -> String {
        var aliasName = shortUrl
        aliasName = aliasName.replacingOccurrences(of: "https://", with: "")
        print("ALIAS NAME:",aliasName)
        
        var len = domain.text?.count
        
        let domainName = "short.fyi"
        aliasName = aliasName.replacingOccurrences(of: domainName+"/", with: "")
        return aliasName
        
    }
    
    func getAlias(aliasName: String){
        
        let apiKey = "e9896260-b45b-11ea-9ec4-b1aa9a0ed929" //later take it from credintials class
        var url = "https://api.shorten.rest/aliases?aliasName=\(aliasName)" //if domain not short, url must contain domainName ---TODO---
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response {
                print(response)
            }
            
            if error == nil {
                
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                print("json == \(String(describing: jsonDict))")
                
                let json = JSON(jsonDict!)
                print("new json",json)
                
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse?.statusCode != 200) {
                    
                    self.displayErrorMessages(errorCode: json["errorCode"].int!, errorMsg: json["errorMessage"].string!)
                }
                
                else {
                
                    let destination = json["destinations"][0]["url"].string!
                    let domainName = json["domainName"].string!
                    DispatchQueue.main.async {
                        self.destinationUrl.text = destination
                        self.domain.text = domainName
                    
                    }
                
                }
                
            } else {
                //error with connection
                print("error with connection")
                
                Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "There was a problem with the connection, make sure you have Wi-Fi or Cellular data turned on and try again.")
            }
        }
        
        task.resume()
        

    }
    
    func displayErrorMessages(errorCode: Int, errorMsg: String){
        
        //maybe later i can create switch with  all error codes..
        Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "\(errorMsg), please try again.")
        
    }
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = shortField.text
        self.view.makeToast("Short URL is copied to clipboard.")
    }
    
}

