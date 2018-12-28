//
//  MockAuth.swift
//  MeetupTweetTests
//
//  Created by Yoshinori Imajo on 2018/12/21.
//  Copyright © 2018 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift
import TwitterAPI

@testable import MeetupTweet

class MockAuth: Auth {
    let sequence: Observable<OAuthSwiftCredential>

    init(sequence: Observable<OAuthSwiftCredential>) {
        self.sequence = sequence
    }

    func authorize(consumerKey: String, consumerSecret: String) -> Observable<OAuthSwiftCredential> {
        return sequence
    }

    func setOAuthClient(oauthClient: OAuthClient) { }
}
