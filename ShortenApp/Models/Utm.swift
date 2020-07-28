//
//  Utm.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 14/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import Foundation
class Utm {
    
    var parameter: String
    var value: String
    
    init(parameter: String, value: String) {
        self.parameter = parameter
        self.value = value
    }
    
    init() {
        parameter = ""
        value = ""
    }
    
}
