//
//  AuthViewController.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/10.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import OAuthSwift
import TwitterAPI

class AuthViewController: NSViewController {

    @IBOutlet weak var consumerKeyTextFeild: NSTextField!
    @IBOutlet weak var consumerSecretTextField: NSTextField!
    @IBOutlet weak var authorizeButton: NSButton!
    

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let consumerKey = UserDefaults.consumerKey() {
            consumerKeyTextFeild.stringValue = consumerKey
        }
        
        if let consumerSecret = UserDefaults.consumerSecret() {
            consumerSecretTextField.stringValue = consumerSecret
        }
        
        let authViewModel = AuthViewModel.init(
            consumerKey: consumerKeyTextFeild.rx_text.asObservable(),
            consumerSecret: consumerSecretTextField.rx_text.asObservable(),
            authrorizeTap: authorizeButton.rx_tap.asObservable()
        )
        
        authViewModel.validated
            .bindTo(authorizeButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        authViewModel.authorized
            .subscribeNext { [unowned self] authorize in
                
                self.dismissController(nil)
            }
            .addDisposableTo(disposeBag)
    }

    @IBAction func tapHelpButton(sender: AnyObject) {
        let url = NSURL(string: "https://apps.twitter.com/")!
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
    @IBAction func tapCloseButton(sender: AnyObject) {
        self.dismissController(nil)
        AppDelegate.sharedInstance.quit()
    }
}
