//
//  AuthViewModel.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/10.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift

import OAuthSwift
import TwitterAPI

class AuthViewModel {
    
    let validated: Observable<Bool>
    let authorized: Observable<Bool>
    
    init(consumerKey: Observable<String>, consumerSecret: Observable<String>, authrorizeTap: Observable<Void>) {
        
        let validatedConsumerKey = consumerKey
            .map {
                return (0 < $0.count)
            }
            .shareReplay(1)
        
        let validatedConsumerSecret = consumerSecret
            .map {
                return (0 < $0.count)
            }
            .shareReplay(1)
        
        validated = Observable.combineLatest(validatedConsumerKey, validatedConsumerSecret) { consumerKey, consumerSecret in
                return consumerKey && consumerSecret
            }
            .distinctUntilChanged()
            .shareReplay(1)

        
        let apiKeyAndSecret = Observable
            .combineLatest(consumerKey, consumerSecret) {
                ($0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                 $1.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
        
        authorized = authrorizeTap.withLatestFrom(apiKeyAndSecret)
            .flatMapLatest { (consumerKey, consumerSecret) -> Observable<Bool>  in
                UserDefaults.setConsumerKey(consumerKey)
                UserDefaults.setConsumerSecret(consumerSecret)
                return AppDelegate.sharedInstance.authorize(consumerKey: consumerKey, consumerSecret: consumerSecret)
                
            }
            .shareReplay(1)
    }
}
