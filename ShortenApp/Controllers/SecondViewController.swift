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
    @IBOutlet weak var utmHeight: NSLayoutConstraint!
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
    
    var aliasName: String = ""
    
    var apiKey = ""
    var domainName = ""
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var extraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        utmTableView.dataSource = self
        utmTableView.delegate = self
        utmTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        snippetTableView.dataSource = self
        snippetTableView.delegate = self
        snippetTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        snippetPicker.dataSource = self
        snippetPicker.delegate = self
        
        saveBtn.isHidden = true
        extraView.isHidden = true
        self.hideKeyboard()
        
        if (UserDefaults.standard.string(forKey: "apiKey") != nil) {
            apiKey = UserDefaults.standard.string(forKey: "apiKey")!
            domainName = UserDefaults.standard.string(forKey: "domain")!
        } else {
            Alert.showBasicAlert(on: self, with: "An error occured", message: "Please complete settings by filling in your API Key.")
        }
        
    } //end viewDidLoad
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.utmHeight?.constant = self.utmTableView.contentSize.height
    }// end viewWillLayoutSubviews
    
    @IBAction func addSnippet(_ sender: Any) {
        isSnippet = true
        if (snippetId != "Select Snippet") {
            insertSnippetRow()
        }
    }
    
    //function that inserts a snippet based on the chosen tracking pixel to the tableview
    func insertSnippetRow(){
        
        let snippet = Snippet(snippetID: snippetId, parameterExample: snippetParameter)
        snippetCells.append(snippet)
        
        let indexPath = IndexPath(row: snippetCells.count - 1, section: 0)
        print(indexPath)
        snippetTableView.beginUpdates()
        snippetTableView.insertRows(at: [indexPath], with: .automatic)
        snippetTableView.endUpdates()
        
        view.endEditing(true)
        
    }// end insertSnippetRow
    
    //function that inserts a utm row based on the entered fields to the tabelview
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
    }// end insertUtmRow
    
    @IBAction func searchBtnTapped(_ sender: Any) {
        //check not empty!
        if (shortField.text == "") {
            Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "Missing short URL field, please try again.")
        } else {
            
            let aliasName = getAliasName(shortUrl: shortField.text!)
            getAlias(aliasName: aliasName)
            extraView.isHidden = false
            saveBtn.isHidden = false
        }
    }
    
    //function that extracts the aliasName from the short url entered by removing the domain name and the '/'
    func getAliasName(shortUrl: String) -> String {
        var alias = shortUrl
        alias = alias.replacingOccurrences(of: "https://", with: "")
        print("ALIAS NAME:",aliasName)
        var len = domainName.count //check android version
        
        alias = alias.replacingOccurrences(of: domainName+"/", with: "")
        self.aliasName = alias
        return aliasName
        
    }// end getAliasName
    
    //function that make a GET API request to getAlias details by sending the aliasName and the json reponse with details such as domain, dest url etc.
    func getAlias(aliasName: String){
        
        var url = "https://api.shorten.rest/aliases?domainName=\(domainName)?aliasName=\(aliasName)"
        
        if (domainName == "short.fyi") {
            url = "https://api.shorten.rest/aliases?aliasName=\(aliasName)"
        }
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
                    let snippets = json["snippets"].array
                    print("SNIPPETs--->",snippets)
                    
                    self.getUtms(url: destination)
                    self.getSnippets(snippetsArray: snippets!)
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
        
        
    }// end getAlias
    
    //function that displays an error alert incase an error occured when making the API request
    func displayErrorMessages(errorCode: Int, errorMsg: String){
        //maybe later i can create switch with  all error codes..
        Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "\(errorMsg), please try again.")
        
    }// end displayErrorMessages
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = shortField.text
        self.view.makeToast("Short URL is copied to clipboard.")
    }
    
    //function that extracts utms embedded in the destination url in order to display them, then removes them from the url for a clean start when trying to edit the short url
    func getUtms(url: String) {
        let url = URL(string: url)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        print("QUERY:",components!.queryItems)
        
        let queryItems = components!.queryItems
        //we have a problem when the url is from the extension :/
        if queryItems != nil {
            for queryItem in queryItems! {
                let utm = Utm(parameter: queryItem.name, value: queryItem.value!)
                insertUtmRow(utm: utm)
            }
        }
        //remove all url components so when we save changes we start in clean slate lol
        components?.queryItems = []
        DispatchQueue.main.async {
            self.destinationUrl.text = components?.url?.absoluteString
            print("NEW DESTINATION->",self.destinationUrl.text)
        }
        
    } //end getUtms
    
    //function that inserts a utm row for the utms that are already embedded in the url by reciving the Utm object
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
        
    } //end insertUtmRow
    
    @IBAction func addUtm(_ sender: Any) {
        isUtm = true
        insertUtmRow()
    }
    
    //function that extracts snippets that are already embedded in the url in order to display them
    func getSnippets(snippetsArray: [JSON]) {
        DispatchQueue.main.async {
            self.snippetTableView.beginUpdates()
        }
        for snippet in snippetsArray {
            let id = snippet["id"].string!
            let parameters = snippet["parameters"].dictionary
            var newParameters = parameters?.description.replacingOccurrences(of: "[", with: "{")
            newParameters = newParameters?.replacingOccurrences(of: "]", with: "}")
            let resultSnip = Snippet(snippetID: id, parameterExample: newParameters!)
            insertSnippetRow(snippet: resultSnip)
        }
        DispatchQueue.main.async {
            self.snippetTableView.endUpdates()
        }
        //delete all snippets from url so we add them when updating from snippetscells
        
    }// end getSnippets
    
    //function that inserts a snippet row for the snippets that already exist in the url by reciving the Snippet object
    func insertSnippetRow(snippet: Snippet){
        
        snippetCells.append(snippet)
        
        let indexPath = IndexPath(row: snippetCells.count - 1, section: 0)
        print(indexPath)
        DispatchQueue.main.async {
            self.snippetTableView.beginUpdates()
            self.snippetTableView.insertRows(at: [indexPath], with: .automatic)
            self.snippetTableView.endUpdates()
            
            self.view.endEditing(true)
        }
        
    } //end insertSnippetRow
    
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        editAlias(aliasName: aliasName)
    }
    
    //function that edits the short url by updating either destination url, domain, snippets, etc by making a 'PUT' API request and sending updates int he request body
    func editAlias(aliasName: String) {
        
        var longUrl = destinationUrl.text
        if (isUtm) {
            longUrl = addUtms(url: longUrl!)
        }
        var url = "https://api.shorten.rest/aliases?domainName=\(domainName)?aliasName=\(aliasName)"
        
        if (domainName == "short.fyi"){
             url = "https://api.shorten.rest/aliases?aliasName=\(aliasName)"
        }
        
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key") //maybe set?
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let result = getSnippetDict(longUrl: longUrl!)
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else { return }
        
        urlRequest.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response {
                print(response)
            }
            
            if error == nil {
                
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                print("json == \(String(describing: jsonDict))")
                
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse?.statusCode != 200) {
                    let json = JSON(jsonDict!)
                    print("new json",json)
                    self.displayErrorMessages(errorCode: json["errorCode"].int!, errorMsg: json["errorMessage"].string!)
                }
                    
                else {
                    //toast
                    DispatchQueue.main.async {
                        self.view.makeToast("Short URL is updated successfully!")
                    }
                }
                
            } else {
                //error with connection
                print("error with connection")
                
                Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "There was a problem with the connection, make sure you have Wi-Fi or Cellular data turned on and try again.")
            }
        }
        
        task.resume()
        
    } // end editAlias
    
    //function that adds utms to the url by going through utms added in the tableview and attaching them to the url
    func addUtms(url: String) -> String {
        
        var queryItems: [URLQueryItem] = []
        
        for utm in utms {
            queryItems.append(URLQueryItem(name: utm.parameter, value: utm.value))
        }
        
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = queryItems
        let result = urlComponents?.url
        print("RESULT OF UTMS-->",result!)
        
        return result!.absoluteString
        
    }// end addUtms
    
    //function that return a dictionary of all snippets added in order  to add them to url when making edits by going through snippets added in the tableview
    func getSnippetDict(longUrl: String) -> [String : [Any]] {
        
        var parameter = [
            
            "destinations": [
                [
                    "url": longUrl,
                    "country": "",
                    "os": ""
                ]
            ]
            ,
            "snippets": [
                
            ]
            
            ] as  [String : [[String : Any]]]
        var array = [Dictionary<String, Any>]()
        
        for snippet in snippetCells {
            
            var cleanParam = snippet.parameterExample.replacingOccurrences(of: "{", with: "")
            cleanParam = cleanParam.replacingOccurrences(of: "}", with: "")
            cleanParam = cleanParam.replacingOccurrences(of: "\n", with: "")
            cleanParam = cleanParam.replacingOccurrences(of: "\"", with: "")
            
            let components = cleanParam.components(separatedBy: ",")
            
            var dictionary: [String : String] = [:]
            var dict = [
                "id": snippet.snippetID,
                "parameters": [
                    
                ]
                ] as [String : Any]
            for component in components{
                let pair = component.components(separatedBy: ":")
                dictionary[pair[0]] = pair[1]
                
            }
            dict["parameters"] = dictionary
            array.append(dict)
            
            
        } //end for loop
        parameter["snippets"] = array
        print("INSIDE->",parameter)
        return parameter
        
    } // end getSnippetDict
    
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

