//
//  TwitterAuth.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/12/07.
//  Copyright © 2018 Yoshinori Imajo. All rights reserved.
//

import Foundation
import OAuthSwift
import TwitterAPI

import RxSwift

protocol Auth {
    func authorize(consumerKey: String, consumerSecret: String) -> Observable<Bool>
}

class TwitterAuth: Auth {
    static let shared = TwitterAuth()
    private(set) var oauthClient: OAuthClient?
    static let callBackHost = "meetup-tweet"

    private init() {}

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<Bool> {

        let oauthSwift = OAuth1Swift(
            consumerKey:     consumerKey,
            consumerSecret:  consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )

        return Observable.create { [unowned self] observer in

            let requestHandle = oauthSwift.authorize(withCallbackURL: "\(type(of: self).callBackHost)://",
                                                     success: { credential, response, parameters in

                TwitterAPIKeysAndTokensStore.save(consumerKey: consumerKey,
                                                  consumerSecret: consumerSecret,
                                                  credential: credential)

                self.oauthClient = TwitterAPIKeysAndTokensStore.resumeOAuthClient()

                observer.onNext(true)
                observer.onCompleted()

            }, failure: { error in
                observer.onError(error)
            })

            return Disposables.create(with: requestHandle!.cancel)
        }
    }
struct TwitterAPIKeysAndTokensStore {

    static func save(consumerKey: String,
                     consumerSecret: String,
                     credential: OAuthSwiftCredential) {

        UserDefaults.setConsumerKey(consumerKey)
        UserDefaults.setConsumerSecret(consumerSecret)

        UserDefaults.setToken(credential.oauthToken)
        UserDefaults.setTokenSecret(credential.oauthTokenSecret)
    }

    static func resumeOAuthClient() -> OAuthClient? {
        guard let consumerKey = UserDefaults.consumerKey(),
            let consumerSecret = UserDefaults.consumerSecret(),
            let token = UserDefaults.token(),
            let tokenSecret = UserDefaults.tokenSecret() else {

            return nil
        }

        return OAuthClient(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            accessToken: token,
            accessTokenSecret: tokenSecret
        )
    }
}
