//
//  MockAuth.swift
//  MeetupTweetTests
//
//  Created by Yoshinori Imajo on 2018/12/21.
//  Copyright © 2018 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift

@testable import MeetupTweet

class MockAuth: Auth {
    let sequence: Observable<Bool>

    init(sequence: Observable<Bool>) {
        self.sequence = sequence
    }

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<Bool> {
        return sequence
    }
}
