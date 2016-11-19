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

    var oauthClient: OAuthClient?
    var requestHandle: OAuthSwiftRequestHandle?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURLEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func quit() {
        NSApplication.shared().terminate(self)
    }
    
    class var sharedInstance: AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }

    func handleGetURLEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = URL(string: urlString) {
            if url.host == "oauth-callback" {
                OAuth1Swift.handle(url: url)
            }
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

            self.requestHandle = oauthSwift.authorize(withCallbackURL: "meetup-tweet://oauth-callback/twitter", success: { credential, response, parameters in
            
                self.oauthClient = OAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: credential.oauthToken, accessTokenSecret: credential.oauthTokenSecret)
                
                observer.onNext(true)

                
            }, failure: { error in
                observer.onError(error)
            })
            

            return Disposables.create()
        }
    }
}
