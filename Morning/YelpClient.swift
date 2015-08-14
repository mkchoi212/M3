//
//  YelpClient.swift
//  Yelp
//
//  Created by Kristen on 2/8/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    var longitude : String?
    var latitude : String?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(long : String, lat : String, consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        var token = BDBOAuthToken(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
        
        longitude = long
        latitude = lat
    }
    
    func searchWithTerm(term: String, additionalParams: [String: String] = [:], success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: (AFHTTPRequestOperation!, NSError!) -> Void) -> AFHTTPRequestOperation! {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        var params = ["term" : term, "ll" : "\(self.longitude!),\(self.latitude!)"]
        for (key, value) in additionalParams {
            params.updateValue(value, forKey: key)
        }
        
        return self.GET("search", parameters: params, success: success, failure: failure)
    }
    
    func getBusiness(id: String, success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: (AFHTTPRequestOperation!, NSError!) -> Void) -> AFHTTPRequestOperation! {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/business
        
        return self.GET("business", parameters: ["id": id], success: success, failure: failure)
    }
}
