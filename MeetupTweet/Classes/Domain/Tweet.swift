//
//  TweetEntity.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/04.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import Himotoki

struct Tweet: Himotoki.Decodable {
    let id: String
    let text: String
    let user: User
    
    fileprivate static var toStringTransformer: Transformer<Int64, String> {
        return Transformer { return String($0) }
    }
    
    static func decode(_ e: Extractor) throws -> Tweet {
        
        return try Tweet(
            id: toStringTransformer.apply(e <| "id"),
            text: e <| "text",
            user: e <| "user"
        )
    }
}

extension Tweet: CommentType {
    var type: Comment {
        return .tweet
    }

    var identifier: String {
        return id
    }
    
    var message: String {
        return text
    }
    
    var imageURL: URL? {
        return URL(string: user.profileImageURLString)
    }

    var name: String {
        return user.screenName
    }
}
