//
//  Credentials.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 14/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import Foundation

class Credentials {
    
    var apiKey: String
    var domain: String
    
    init(apiKey: String, domain: String) {
        self.apiKey = apiKey
        self.domain = domain
    }
        
    init() {
        apiKey = ""
        domain = "short.fyi"
    }
    
        
}
