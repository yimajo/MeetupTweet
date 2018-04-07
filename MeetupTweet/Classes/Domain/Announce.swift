//
//  Comment.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/21.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation

struct Announce: CommentType {
    let id: String
    let text: String

    init(search: String) {
        id = Announce.createId()
        text = Announce.meessage(search)
    }

    func type() -> Comment {
        return .announce
    }
    
    func identifier() -> String {
        return id
    }
    
    func message() -> String {
        return text
    }
    
    func imageURL() -> URL? {
        return nil
    }
}

private extension Announce {

    static func meessage(_ search: String) -> String {
        return "Twiter Stream APIを\(search)で取得中です"
    }

    static func createId() -> String {
        return UUID().uuidString
    }
}
