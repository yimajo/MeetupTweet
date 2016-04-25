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
    
    func type() -> Comment {
        return .Announce
    }
    
    func identifier() -> String {
        return id
    }
    
    func message() -> String {
        return text
    }
    
    func imageURL() -> NSURL? {
        return nil
    }
}