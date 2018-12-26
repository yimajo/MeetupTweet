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
