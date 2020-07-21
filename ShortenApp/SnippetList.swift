//
//  SnippetList.swift
//  ShortenApp
//
//  Created by Lina Alkhodair on 15/07/2020.
//  Copyright © 2020 Lina Alkhodair. All rights reserved.
//

import Foundation
class SnippetList {
    private var ID: String
    private var parameterExample: String
    
    init(ID: String, parameterExample: String){
        self.ID = ID
        self.parameterExample = parameterExample
    }
    
    func getParameterExample(ID: String) -> String {
        self.ID = ID
        
        switch (ID) {
       case "GoogleAnalytics":
                       parameterExample = "{\n\"trackingId\":\"YOUR_TRACKING_ID\",\n\"event\":\"YOUR_EVENT\"\n}"
                       
        case "FacebookPixel":
                       parameterExample = "{\n \"id\":\"YOUR_ID\",\n\"event\":\"EVENT_NAME\"\n}"
                       
        case "GoogleConversionPixel":
                       parameterExample = "{\n\"conversionId\":\"YOUR_CONVERSION_ID\",\n\"gtagConversionEvent\":{\n\"sendTo\": \"INSERT_SENDTO\",\n\"value\":\"1.0\",\n\"currency\":\"USD\"\n}\n}"
                       
        case "LinkedInPixel":
                       parameterExample = "{\n\"partnerId\":\"YOUR_PARTNER_ID\"\n}"
                       
        case "AdrollPixel":
                       parameterExample = "{\n\"advId\":\"YOUR_ADV_ID\",\n\"pixId\":\"YOUR_PIX_ID\"\n}"
                       
        case "TaboolaPixel":
                       parameterExample = "{\n\"id\":\"YOUR_TABOOLA_ID\",\n\"eventName\":\"YOUR_EVENT_NAME\"\n}"
                       
       case "BingPixel":
                       parameterExample = "{\n\"id\":\"YOUR_ID\"\n}"
                       
        case "PinterestPixel":
                       parameterExample = "{\n\"tagId\":\"YOUR_TAG_ID\"\n}"
                       
        case "SnapchatPixel":
                       parameterExample = "{\n\"pixelId\":\"YOUR_PIXEL_ID\",\n\"userEmail\":\"INSERT_USER_EMAIL\",\n \"eventName\": \"PAGE_VIEW\"\n}"
                       
          default:
                       parameterExample = "NA"
                       


        }//end switch
        
        return parameterExample
    }
    

    
    
    
}
