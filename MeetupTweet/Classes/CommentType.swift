//
//  CommentType.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/21.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//
import Foundation

enum Comment {
    case Tweet
    case Announce
}

protocol CommentType {
    func type() -> Comment
    
    func identifier() -> String
    func message() -> String
    func imageURL() -> NSURL?
}
