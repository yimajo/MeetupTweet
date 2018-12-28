//
//  AuthViewModelSpec.swift
//  MeetupTweetTests
//
//  Created by Yoshinori Imajo on 2018/12/20.
//  Copyright © 2018 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import Quick
import Nimble
import OAuthSwift
import TwitterAPI

@testable import MeetupTweet

extension Recorded: Equatable where Value: Equatable {}
extension Event: Equatable where Element: Equatable {}

class AuthViewModelSpec: QuickSpec {

    override func spec() {
        describe("バリデーションと認可の出力を検証") {
            let disposeBag = DisposeBag()
            var scheduler: TestScheduler!

            var consumerKey: TestableObservable<String>!
            var consumerSecret: TestableObservable<String>!
            var authroizeTap: TestableObservable<()>!

            var validationObserver: TestableObserver<Bool>!
            var authObserver: TestableObserver<Bool>!

            var userDefaults: MeetupTweet.UserDefaults!

            context("入力が0文字の初期状態から1文字以上文字列になった場合") {

                beforeEach {

                    userDefaults = MeetupTweet.UserDefaults(suiteName: "test")

                    scheduler = TestScheduler(initialClock: 0)
                    consumerKey = scheduler.createHotObservable([
                        Recorded.next(0, ""),
                        Recorded.next(20, "consumerKey"),
                    ])

                    consumerSecret = scheduler.createHotObservable([
                        Recorded.next(0, ""),
                        Recorded.next(21, "consumerSecret"),
                    ])

                    authroizeTap = scheduler.createHotObservable([
                        Recorded.next(30, ()),
                    ])
                }

                context("認可されている") {

                    beforeEach {
                        let credential = OAuthSwiftCredential(consumerKey: "testConsumerKey",
                                                              consumerSecret: "testConsumerSecret")
                        credential.oauthToken = "testToken"
                        credential.oauthTokenSecret = "testTokenSecret"

                        let mockAuth = MockAuth(sequence: Observable.just(credential))

                        let viewModel = AuthViewModel(consumerKey: consumerKey.asObservable(),
                                                      consumerSecret: consumerSecret.asObservable(),
                                                      authrorizeTap: authroizeTap.asObservable(),
                                                      twitterAuth: mockAuth,
                                                      userDefaults: userDefaults)

                        validationObserver = scheduler.createObserver(Bool.self)
                        authObserver = scheduler.createObserver(Bool.self)

                        viewModel.validated
                            .bind(to: validationObserver)
                            .disposed(by: disposeBag)

                        viewModel.authorized
                            .drive(authObserver)
                            .disposed(by: disposeBag)

                        scheduler.start()
                    }

                    it("バリデーションが問題ないならその結果どおり") {
                        expect(validationObserver.events).to(equal([
                            Recorded.next(0, false),
                            Recorded.next(20, false),
                            Recorded.next(21, true)
                        ]))
                    }
                    it("バリデーションが問題ないなら認可される") {
                        expect(authObserver.events).to(equal([
                            Recorded.next(30, true)
                        ]))
                    }
                }

                context("認可されていない") {

                    beforeEach {
                        let credential = OAuthSwiftCredential(consumerKey: "testConsumerKey",
                                                              consumerSecret: "testConsumerSecret")

                        let mockAuth = MockAuth(sequence: Observable.just(credential))

                        let viewModel = AuthViewModel(consumerKey: consumerKey.asObservable(),
                                                      consumerSecret: consumerSecret.asObservable(),
                                                      authrorizeTap: authroizeTap.asObservable(),
                                                      twitterAuth: mockAuth,
                                                      userDefaults: userDefaults)

                        authObserver = scheduler.createObserver(Bool.self)

                        viewModel.authorized
                            .drive(authObserver)
                            .disposed(by: disposeBag)

                        scheduler.start()
                    }

                    it("バリデーションが問題なくても認可されない") {
                        expect(authObserver.events).to(equal([
                            Recorded.next(30, false)
                        ]))
                    }
                }
            }
        }
    }
}
