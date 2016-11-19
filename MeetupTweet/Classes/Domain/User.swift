//
//  User.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/03.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import Himotoki

struct User: Decodable {
    let profileImageURLString: String
    
    static func decode(_ e: Extractor) throws -> User {
        return try User(
            profileImageURLString: e <| "profile_image_url"
        )
    }
}
