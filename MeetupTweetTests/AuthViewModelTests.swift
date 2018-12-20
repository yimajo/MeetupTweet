//
//  AuthViewModelTests.swift
//  MeetupTweetTests
//
//  Created by Yoshinori Imajo on 2018/12/07.
//  Copyright © 2018 Yoshinori Imajo. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import MeetupTweet

class AuthViewModelTests: XCTestCase {

    let disposeBag = DisposeBag()
    var scheduler: TestScheduler!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testバリデーション確認() {
        let consumerKey = scheduler.createHotObservable([
            Recorded.next(0, ""),
            Recorded.next(20, "consumerKey"),
        ])

        let consumerSecret = scheduler.createHotObservable([
            Recorded.next(0, ""),
            Recorded.next(21, "Swift"),
         ])

        let authroizeTap = scheduler.createHotObservable([
            Recorded.next(0, ()), // validationだけなのでここではタップ無関係
        ])

        let mockSequence = Observable.of(true)

        let viewModel = AuthViewModel(consumerKey: consumerKey.asObservable(),
                                      consumerSecret: consumerSecret.asObservable(),
                                      authrorizeTap: authroizeTap.asObservable(),
                                      twitterAuth: MockAuth(sequence: mockSequence))


        let observer = scheduler.createObserver(Bool.self)

        viewModel.validated
            .bind(to: observer)
            .disposed(by: disposeBag)

        let expectedEvents = [
            Recorded.next(0, false),
            Recorded.next(20, false),
            Recorded.next(21, true)
        ]

        scheduler.start()
        XCTAssertEqual(observer.events, expectedEvents)
    }

    func test入力と出力確認() {
        let consumerKey = scheduler.createHotObservable([
            Recorded.next(1, "S"),
        ])

        let consumerSecret = scheduler.createHotObservable([
            Recorded.next(1, "S"),
        ])

        let authroizeTap = scheduler.createHotObservable([
            Recorded.next(2, ()),
            Recorded.next(3, ())
        ])

        let mockSequence = Observable.of(true)

        let viewModel = AuthViewModel(consumerKey: consumerKey.asObservable(),
                                      consumerSecret: consumerSecret.asObservable(),
                                      authrorizeTap: authroizeTap.asObservable(),
                                      twitterAuth: MockAuth(sequence: mockSequence))


        let observer = scheduler.createObserver(Bool.self)

        viewModel.authorized
            .drive(observer)
            .disposed(by: disposeBag)

        // 5.
        let expectedEvents = [
            Recorded.next(2, true),
            Recorded.next(3, true)
        ]

        scheduler.start()
        XCTAssertEqual(observer.events, expectedEvents)
    }
}

class MockAuth: Auth {
    let sequence: Observable<Bool>

    init(sequence: Observable<Bool>) {
        self.sequence = sequence
    }

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<Bool> {
        return sequence
    }
}
