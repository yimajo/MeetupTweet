//
//  TweetEntity.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/04.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import Himotoki

struct Tweet: Decodable {
    let id: String
    let text: String
    let user: User
    
    private static var toStringTransformer: Transformer<Int64, String> {
        return Transformer { return String($0) }
    }
    
    static func decode(e: Extractor) throws -> Tweet {
        
        return try Tweet(
            id: toStringTransformer.apply(e <| "id"),
            text: e <| "text",
            user: e <| "user"
        )
    }
}

extension Tweet: CommentType {
    func type() -> Comment {
        return .Tweet
    }
    
    func identifier() -> String {
        return id
    }
    
    func message() -> String {
        return text
    }
    
    func imageURL() -> NSURL? {
        return NSURL(string: user.profileImageURLString)
    }
}