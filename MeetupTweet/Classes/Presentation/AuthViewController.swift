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
        
        let authViewModel = AuthViewModel(
            consumerKey: consumerKeyTextFeild.rx.text.orEmpty.asObservable(),
            consumerSecret: consumerSecretTextField.rx.text.orEmpty.asObservable(),
            authrorizeTap: authorizeButton.rx.tap.asObservable()
        )
        
        authViewModel.validated
            .bindTo(authorizeButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        authViewModel.authorized
            .subscribe(onNext: { [unowned self] authorize in
                self.dismiss(nil)
            }, onError: { error in
                print(error)
            }).addDisposableTo(disposeBag)
    }

    @IBAction func tapHelpButton(_ sender: AnyObject) {
        let url = URL(string: "https://apps.twitter.com/")!
        NSWorkspace.shared().open(url)
    }
    
    @IBAction func tapCloseButton(_ sender: AnyObject) {
        self.dismiss(nil)
        AppDelegate.sharedInstance.quit()
    }
}
