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
    
    init(consumerKey: Observable<String>, consumerSecret: Observable<String>, authrorizeTap: Observable<()>) {
        
        let validatedConsumerKey = consumerKey
            .map { 0 < $0.count }
            .share(replay: 1)

        let validatedConsumerSecret = consumerSecret
            .map { 0 < $0.count }
            .share(replay: 1)

        validated = Observable.combineLatest(validatedConsumerKey,
                                             validatedConsumerSecret) {
                $0 && $1
            }
            .share(replay: 1)
            .distinctUntilChanged()

        
        let apiKeyAndSecret = Observable.combineLatest(consumerKey, consumerSecret) {
                ($0.trimmingCharacters(in: .whitespacesAndNewlines),
                 $1.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            .share(replay: 1)
        
        authorized = authrorizeTap.withLatestFrom(apiKeyAndSecret)
            .flatMapLatest { key, secret -> Observable<Bool>  in
                UserDefaults.setConsumerKey(key)
                UserDefaults.setConsumerSecret(secret)

                return AppDelegate.sharedInstance.authorize(consumerKey: key,
                                                            consumerSecret: secret)
                
            }
            .share(replay: 1)
    }
}
