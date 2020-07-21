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
    
    @IBOutlet weak var utmParam: UITextField!
    @IBOutlet weak var utmValue: UITextField!
    @IBOutlet weak var utmTableView: UITableView!
    var isUtm: Bool = false //variable to check if utms has been added
    var utms: [Utm] = []
    
    @IBOutlet weak var snippetPicker: UIPickerView!
    @IBOutlet weak var snippetTableView: UITableView!
    var isSnippet: Bool = false
    var snippetCells: [Snippet] = []
    var snippetId: String = ""
    var snippetParameter: String = ""
    
    var snippets = ["Select Snippet","GoogleAnalytics", "FacebookPixel", "GoogleConversionPixel", "LinkedInPixel",
    "AdrollPixel", "TaboolaPixel", "BingPixel", "PinterestPixel", "SnapchatPixel"
    ]
    
    var snippetList = SnippetList(ID: "", parameterExample: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        utmTableView.dataSource = self
        utmTableView.delegate = self
        utmTableView.tableFooterView = UIView(frame: CGRect.zero)
                
        snippetTableView.dataSource = self
        snippetTableView.delegate = self
        snippetTableView.tableFooterView = UIView(frame: CGRect.zero)
        //        utmTableView.reloadData()
        //        snippetTableView.reloadData()
                
        snippetPicker.dataSource = self
        snippetPicker.delegate = self
        
    }
    
    @IBAction func addSnippet(_ sender: Any) {
        isSnippet = true
        if (snippetId != "Select Snippet") {
        insertSnippetRow()
        }
    }
    
    func insertSnippetRow(){
        
        let snippet = Snippet(snippetID: snippetId, parameterExample: snippetParameter)
        snippetCells.append(snippet)
        
        let indexPath = IndexPath(row: snippetCells.count - 1, section: 0)
        print(indexPath)
        snippetTableView.beginUpdates()
        snippetTableView.insertRows(at: [indexPath], with: .automatic)
        snippetTableView.endUpdates()

        view.endEditing(true)
        
    }
    
    func insertUtmRow() {
            
        let param = utmParam.text!
        let value = utmValue.text!
        var isValid = true
        
        if param.isEmpty || value.isEmpty {
            Alert.showBasicAlert(on: self, with: "Missing Field!", message: "Please fill in all UTM fields and try again")
            isValid = false
        }
        
        if isValid {
            
        let utm = Utm(parameter: param, value: value)
        utms.append(utm)
        print("HERE!!!!",utms[0])
            
            let indexPath = IndexPath(row: utms.count - 1, section: 0)
            
            utmTableView.beginUpdates()
            utmTableView.insertRows(at: [indexPath], with: .automatic)
            utmTableView.endUpdates()
            
            utmParam.text = ""
            utmValue.text = ""
            view.endEditing(true)
            
        }
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
                    self.getUtms(url: destination)
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
    
    func getUtms(url: String) {
        let url = URL(string: url)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        print("QUERY:",components!.queryItems)
        
        let queryItems = components!.queryItems
        //we have a problem when the url is from the extension :/
        for queryItem in queryItems! {
            let utm = Utm(parameter: queryItem.name, value: queryItem.value!)
            insertUtmRow(utm: utm)
        }
        
        //remove all url components so when we save changes we start in clean slate lol
        components?.queryItems = []
        DispatchQueue.main.async {
            self.destinationUrl.text = components?.url?.absoluteString
            print("NEW DESTINATION->",self.destinationUrl.text)
        }
    }
    
    func insertUtmRow(utm: Utm) {
    
        utms.append(utm)
        print("HERE!!!!",utms[0])
            
            let indexPath = IndexPath(row: utms.count - 1, section: 0)
            
        DispatchQueue.main.async {
            self.utmTableView.beginUpdates()
            self.utmTableView.insertRows(at: [indexPath], with: .automatic)
            self.utmTableView.endUpdates()
            self.view.endEditing(true)
        }

    }
    
    @IBAction func addUtm(_ sender: Any) {
        isUtm = true
        insertUtmRow()
    }
    
    
} //end SecondViewController

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case utmTableView:
            return utms.count
            
        case snippetTableView:
            return snippetCells.count
            
        default:
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case utmTableView:
            let utm = utms[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "UtmCell") as! UtmCell
            cell.paramField.text = utm.parameter
            cell.valueField.text = utm.value
            
            return cell
        case snippetTableView:
            let snippet = snippetCells[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "snippetCell") as! SnippetCell
            cell.snippetId.text = snippet.snippetID
            cell.snippetParameter.text = snippet.parameterExample
            return cell
        
        default:
            return UITableViewCell()
        }

        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            switch tableView {
            case utmTableView:
                utms.remove(at: indexPath.row) //anther table view
                utmTableView.beginUpdates()
                utmTableView.deleteRows(at: [indexPath], with: .automatic)
                utmTableView.endUpdates()
            
            case snippetTableView:
                snippetCells.remove(at: indexPath.row) //anther table view
                
                snippetTableView.beginUpdates()
                snippetTableView.deleteRows(at: [indexPath], with: .automatic)
                snippetTableView.endUpdates()
            default: break
                
            } //end switch

        } //end if
    }
}

extension SecondViewController: UIPickerViewDataSource, UIPickerViewDelegate {
func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1 //number of columns
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return snippets.count
}
    
func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return snippets[row]
}
    
func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected::::",snippets[row])
        let parameterExample = snippetList.getParameterExample(ID: snippets[row])
    
        snippetId = snippets[row]
        snippetParameter = parameterExample
}

}
