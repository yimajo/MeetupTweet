//
//  UserDefaults.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/11.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation

struct UserDefaults {
    
    fileprivate static let consumerKeyName = "consumerKey"
    fileprivate static let consumerSecretName = "consumerSecret"
    
    static func setConsumerKey(_ consumerKey: String?) {
         Foundation.UserDefaults.standard.setValue(consumerKey, forKey: self.consumerKeyName)
    }
    
    static func consumerKey() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: consumerKeyName)
    }
    
    static func setConsumerSecret(_ consumerSecret: String?) {
        Foundation.UserDefaults.standard.setValue(consumerSecret, forKey: self.consumerSecretName)
    }
    
    static func consumerSecret() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: consumerSecretName)
    }
}
