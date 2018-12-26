//
//  AuthViewModel.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/10.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import OAuthSwift
import TwitterAPI

class AuthViewModel {
    
    let validated: Observable<Bool>
    let authorized: Driver<Bool>
    let errorMessage: Driver<Error>

    init(consumerKey: Observable<String>,
         consumerSecret: Observable<String>,
         authrorizeTap: Observable<()>,
         twitterAuth: Auth) {
        
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

        
        let apiKeyAndSecret = Observable.combineLatest(consumerKey, consumerSecret) {
                ($0.trimmingCharacters(in: .whitespacesAndNewlines),
                 $1.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            .share(replay: 1)
        
        let result = authrorizeTap.withLatestFrom(apiKeyAndSecret)
            .flatMapLatest { key, secret -> Observable<Event<Bool>>  in
                return twitterAuth
                    .authorize(consumerKey: key, consumerSecret: secret)
                    .materialize()
            }
            .share(replay: 1)

        authorized = result
            .elements()
            .asDriver(onErrorDriveWith: .never())

        errorMessage = result.errors()
            .asDriver(onErrorDriveWith: .never())
    }
}
