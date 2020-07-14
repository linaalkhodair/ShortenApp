//
//  FirstViewController.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 12/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import UIKit
import SwiftyJSON

class FirstViewController: UIViewController {

    @IBOutlet weak var destinationUrl: UITextField!
    
    @IBOutlet weak var shortURL: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func shortenBtnClicked(_ sender: Any) {
            createAlias()

    } //end shortenBtnClicked
    
    
    func createAlias(){
        
            let apiKey = "e9896260-b45b-11ea-9ec4-b1aa9a0ed929" //later take it from credintials class
            let longUrl = destinationUrl.text
            var url = "https://api.shorten.rest/aliases?aliasName=/@rnd"
            url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key") //maybe set?
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let parameter = [
                "destinations": [
                    [
                        "url": longUrl,
                        "country": "",
                        "os": ""
                    ]
                ]
            ]
        
            print(parameter)
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: []) else { return }
            urlRequest.httpBody = httpBody
            
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if let response = response {
                    print(response)
                }
                
                if error == nil {
                    
                    let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    print("json == \(String(describing: jsonDict))")
                    
                    let json = JSON(jsonDict!)
                    print("new json",json)
                    
                    if json["errorCode"].string != "" {
                        
                        self.displayErrorMessages(errorCode: json["errorCode"].int!, errorMsg: json["errorMessage"].string!)
                    }
                    
                    else {
                    
                    let shortened = json["shortUrl"].string!
                    DispatchQueue.main.async {
                        self.shortURL.text = shortened
                    }
                    print("short url:",json["shortUrl"].string!)
                    
                    }
                    
                } else {
                    //error with connection
                    print("error with connection")
                    //--TODO-- show dialog?
                    Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "There was a problem with the connection, make sure you have Wi-Fi or Cellular data turned on and try again.")
                }
            }
            
            task.resume()
    
        
    } //end createAlias
    
    func displayErrorMessages(errorCode: Int, errorMsg: String){
        
        //maybe later i can create switch with  all error codes..
        Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "\(errorMsg), please try again.")
        
        
    }
    
}

