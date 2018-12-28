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
    private static let tokenKeyName = "tokenKey"
    private static let tokenSecretName = "tokenSecret"

    private let defaults: Foundation.UserDefaults

    init(defaults: Foundation.UserDefaults = Foundation.UserDefaults.standard) {
        self.defaults = defaults
    }

    init(suiteName: String) {
        self.defaults = Foundation.UserDefaults(suiteName: suiteName)!
    }

    func setConsumerKey(_ consumerKey: String?) {
        defaults.setValue(consumerKey, forKey: UserDefaults.consumerKeyName)
    }

    func consumerKey() -> String? {
        return defaults.string(forKey: UserDefaults.consumerKeyName)
    }

    func setConsumerSecret(_ consumerSecret: String?) {
        defaults.setValue(consumerSecret, forKey: UserDefaults.consumerSecretName)
    }

    func consumerSecret() -> String? {
        return defaults.string(forKey: UserDefaults.consumerSecretName)
    }

    func setToken(_ token: String) {
        defaults.setValue(token, forKey: UserDefaults.tokenKeyName)
    }

    func setTokenSecret(_ tokenSecret: String) {
        defaults.setValue(tokenSecret, forKey: UserDefaults.tokenSecretName)
    }

    func token() -> String? {
        return defaults.string(forKey: UserDefaults.tokenKeyName)
    }

    func tokenSecret() -> String? {
        return defaults.string(forKey: UserDefaults.tokenSecretName)
    }
}
