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
    func authorize(consumerKey: String, consumerSecret: String) -> Observable<OAuthSwiftCredential>

    func setOAuthClient(oauthClient: OAuthClient)
}

class TwitterAuth: Auth {
    static let shared = TwitterAuth()
    static let callBackHost = "meetup-tweet"
    var oauthClient: OAuthClient?

    private init() {}

    func setOAuthClient(oauthClient: OAuthClient) {
        self.oauthClient = oauthClient
    }

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<OAuthSwiftCredential> {

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

                observer.onNext(credential)
                observer.onCompleted()

            }, failure: { error in
                observer.onError(error)
            })

            return Disposables.create(with: requestHandle!.cancel)
        }
    }

    func resumeTwitterAuth(userDefaults: UserDefaults) {
        if oauthClient == nil {
            oauthClient = TwitterAPIKeysAndTokensStore.resumeOAuthClient(userDefaults: userDefaults)
        }
    }
}

struct TwitterAPIKeysAndTokensStore {

    static func save(consumerKey: String, consumerSecret: String, userDefaults: UserDefaults) {
        userDefaults.setConsumerKey(consumerKey)
        userDefaults.setConsumerSecret(consumerSecret)
    }

    static func save(credential: OAuthSwiftCredential, userDefaults: UserDefaults) {
        userDefaults.setToken(credential.oauthToken)
        userDefaults.setTokenSecret(credential.oauthTokenSecret)
    }

    static func resumeOAuthClient(userDefaults: UserDefaults) -> OAuthClient? {
        guard let consumerKey = userDefaults.consumerKey(),
            let consumerSecret = userDefaults.consumerSecret(),
            let token = userDefaults.token(),
            let tokenSecret = userDefaults.tokenSecret(),
            !token.isEmpty, !tokenSecret.isEmpty else {

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
