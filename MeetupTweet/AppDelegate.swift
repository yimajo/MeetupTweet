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
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURLEvent(_:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    class var sharedInstance: AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }

    func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue, url = NSURL(string: urlString) {
            if url.host == "oauth-callback" {
                OAuth1Swift.handleOpenURL(url)
            }
        }
    }
    

    func authorize(consumerKey consumerKey: String, consumerSecret: String) -> Observable<Bool> {
        
        let oauthSwift = OAuth1Swift(
            consumerKey:     consumerKey,
            consumerSecret:  consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )

        return Observable.create { observer in
            oauthSwift.authorizeWithCallbackURL(NSURL(string: "meetup-tweet://oauth-callback/twitter")!,
                success: { credential, response in
                    
                    self.oauthClient = OAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: credential.oauth_token, accessTokenSecret: credential.oauth_token_secret)
                    
                    observer.onNext(true)
                    
                }, failure: { error in
                    
                    observer.onError(error)
                }
            )
            return AnonymousDisposable{ }
        }
    }
}