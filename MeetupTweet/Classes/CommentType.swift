//
//  CommentType.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/21.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//
import Foundation

enum Comment {
    case tweet
    case announce
}

protocol CommentType {
    var type: Comment { get }
    
    var identifier: String { get }
    var message: String { get }
    var imageURL: URL? { get }
    var name: String { get }
}
