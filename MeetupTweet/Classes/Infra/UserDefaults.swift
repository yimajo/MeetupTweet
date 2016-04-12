//
//  UserDefaults.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/11.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation

struct UserDefaults {
    
    private static let consumerKeyName = "consumerKey"
    private static let consumerSecretName = "consumerSecret"
    
    static func setConsumerKey(consumerKey: String) {
         NSUserDefaults.standardUserDefaults().setValue(consumerKey, forKey: self.consumerKeyName)
    }
    
    static func consumerKey() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(consumerKeyName)
    }
    
    static func setConsumerSecret(consumerSecret: String) {
        NSUserDefaults.standardUserDefaults().setValue(consumerSecret, forKey: self.consumerSecretName)
    }
    
    static func consumerSecret() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(consumerSecretName)
    }
}