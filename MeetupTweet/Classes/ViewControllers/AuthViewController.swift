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

    @IBOutlet weak var consumerKeyTextFeild: NSTextField! {
        didSet {
            if let consumerKey = UserDefaults.consumerKey() {
                consumerKeyTextFeild.stringValue = consumerKey.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    @IBOutlet weak var consumerSecretTextField: NSTextField! {
        didSet {
            if let consumerSecret = UserDefaults.consumerSecret() {
                consumerSecretTextField.stringValue = consumerSecret.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    @IBOutlet weak var authorizeButton: NSButton!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let authViewModel = AuthViewModel(
            consumerKey: consumerKeyTextFeild.rx.text.orEmpty.asObservable(),
            consumerSecret: consumerSecretTextField.rx.text.orEmpty.asObservable(),
            authrorizeTap: authorizeButton.rx.tap.asObservable(),
            twitterAuth: TwitterAuth.shared
        )

        authViewModel.validated
            .bind(to: authorizeButton.rx.isEnabled)
            .disposed(by: disposeBag)

        authViewModel.authorized
            .drive(onNext: { [unowned self] _ in
                self.dismiss(nil)
            })
            .disposed(by: disposeBag)

        authViewModel.errorMessage
            .drive(onNext: { [unowned self] in
                let info = self.configureAlertInfo(from: $0)

                let alert = NSAlert()
                alert.messageText = info.title
                alert.informativeText = info.text
                alert.addButton(withTitle: "OK")
                alert.runModal()
            })
            .disposed(by: disposeBag)
    }

    @IBAction func tapHelpButton(_ sender: AnyObject) {
        let url = URL(string: "https://apps.twitter.com/")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func tapCloseButton(_ sender: AnyObject) {
        dismiss(nil)
        AppDelegate.shared.quit()
    }
}

private extension AuthViewController {
    func configureAlertInfo(from error: Error) -> (title: String, text: String) {

        if let error = error as? OAuthSwiftError {
            switch error {
            case .requestError(error: _):
                let title = "API Key, Secretに関するエラー"
                let text = "存在しないAPI Key, Secretを入力しているか、もしくは、あなたのTwitter DeveloperのApp設定にてCallbackURLに\(TwitterAuth.callBackHost)://が追加されていない可能性があります。CallbackURLはブラウザ認証後にこのアプリを起動するためのURLスキーマです。"

                return (title: title, text: text)
            default:
                return (title: "認証に関するエラー", text: error.description)
            }
        }

        return (title: "原因不明のエラー",
                text: "このアプリケーションは実行するmacに対応していない可能性があります")
    }
}
