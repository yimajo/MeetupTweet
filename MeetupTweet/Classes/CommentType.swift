//
//  CommentType.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/21.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//
import Foundation

enum CommentType {
    case Tweet
    case Announce
}

protocol Comment {
    func type() -> CommentType
    
    func identifier() -> String
    func message() -> String
    func imageURL() -> NSURL?
}
