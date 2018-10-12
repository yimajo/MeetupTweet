//
//  AppDelegate.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/03.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Cocoa
import OAuthSwift
import TwitterAPI
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private(set) var oauthClient: OAuthClient?
    private var requestHandle: OAuthSwiftRequestHandle?
    let callBackHost = "meetup-tweet"

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURLEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func quit() {
        NSApplication.shared.terminate(self)
    }
    
    class var shared: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }

    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
            let url = URL(string: urlString),
            url.scheme == callBackHost {

            OAuth1Swift.handle(url: url)
        }
    }

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<Bool> {
        
        let oauthSwift = OAuth1Swift(
            consumerKey:     consumerKey,
            consumerSecret:  consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )

        return Observable.create { [unowned self] observer in

            self.requestHandle = oauthSwift.authorize(withCallbackURL: "\(self.callBackHost)://", success: { credential, response, parameters in

                UserDefaults.setToken(credential.oauthToken)
                UserDefaults.setTokenSecret(credential.oauthTokenSecret)

                self.oauthClient = OAuthClient(
                    consumerKey: consumerKey,
                    consumerSecret: consumerSecret,
                    accessToken: credential.oauthToken,
                    accessTokenSecret: credential.oauthTokenSecret
                )
                
                observer.onNext(true)

            }, failure: { error in
                observer.onError(error)
            })

            return Disposables.create()
        }
    }

    func applyToken() {
        guard let consumerKey = UserDefaults.consumerKey(),
            let consumerSecret = UserDefaults.consumerSecret(),
            let token = UserDefaults.token(),
            let tokenSecret = UserDefaults.tokenSecret() else {

            return
        }

        oauthClient = OAuthClient(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            accessToken: token,
            accessTokenSecret: tokenSecret
        )

    }
}
