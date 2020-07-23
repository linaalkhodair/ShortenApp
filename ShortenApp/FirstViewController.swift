//
//  FirstViewController.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 12/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift

class FirstViewController: UIViewController {

    @IBOutlet weak var destinationUrl: UITextField!
    @IBOutlet weak var shortURL: UITextField!
    @IBOutlet weak var utmTableView: UITableView!
    @IBOutlet weak var paramField: UITextField!
    @IBOutlet weak var valueField: UITextField!
        
    @IBOutlet weak var snippetPicker: UIPickerView!
    
    @IBOutlet weak var snippetTableView: UITableView!
    @IBOutlet weak var extraView: UIView!
    @IBOutlet weak var plusSign: UIImageView!
    @IBOutlet weak var minusSign: UIImageView!
    
    var isUtm: Bool = false //variable to check if utms has been added
    var isSnippet: Bool = false
    
    var utms: [Utm] = []
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
        
        snippetPicker.dataSource = self
        snippetPicker.delegate = self
        
        extraView.isHidden = true //hidden
        
        
    }

    @IBAction func expandBtn(_ sender: Any) {
        
        if (extraView.isHidden) {
            extraView.isHidden = false
            plusSign.isHidden = true
            minusSign.isHidden = false
        }
        else {
            extraView.isHidden = true
            plusSign.isHidden = false
            minusSign.isHidden = true
        }
        
    }
    
    
    @IBAction func addSnippet(_ sender: Any) {
        isSnippet = true
        if (snippetId != "Select Snippet") {
        insertSnippetRow()
        }
    }
    
    @IBAction func shortenBtnClicked(_ sender: Any) {
            createAlias()

    } //end shortenBtnClicked
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
        isUtm = true
        insertUtmRow()
    }
    
    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = shortURL.text
        self.view.makeToast("Short URL is copied to clipboard.")
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
            
        let param = paramField.text!
        let value = valueField.text!
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
            
            paramField.text = ""
            valueField.text = ""
            view.endEditing(true)
            
        }
    }
    
    
    func createAlias(){
        
            let apiKey = "e9896260-b45b-11ea-9ec4-b1aa9a0ed929" //later take it from credintials class
            var longUrl = destinationUrl.text
            if (isUtm) {
                longUrl = addUtms(url: longUrl!)
            }
            var url = "https://api.shorten.rest/aliases?aliasName=/@rnd"
            url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
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
                    
                    let json = JSON(jsonDict!)
                    print("new json",json)
                    
                    let httpResponse = response as? HTTPURLResponse
                    if (httpResponse?.statusCode != 200) {
                        
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
                    
                    Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "There was a problem with the connection, make sure you have Wi-Fi or Cellular data turned on and try again.")
                }
            }
            
            task.resume()
    
        
    } //end createAlias
    
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
    }
    
    
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
        
    }
    
    
    
    func displayErrorMessages(errorCode: Int, errorMsg: String){
        
        //maybe later i can create switch with  all error codes..
        Alert.showBasicAlert(on: self, with: "Something went wrong!", message: "\(errorMsg), please try again.")
        
    }
    
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension FirstViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
