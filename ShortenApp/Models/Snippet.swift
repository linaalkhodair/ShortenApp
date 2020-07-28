//
//  Snippet.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 16/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import Foundation
class Snippet {
    
    var snippetID: String
    var parameterExample: String
    
    init(snippetID: String, parameterExample: String){
        
        self.snippetID = snippetID
        self.parameterExample = parameterExample
    }
    
    init() {
        snippetID = ""
        parameterExample = ""
    }
    
}
