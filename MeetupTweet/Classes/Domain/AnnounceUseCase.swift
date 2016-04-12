//
//  AnnounceUseCase.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/09.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift

class AnnounceUseCase {
    
    class func intervalTextStream(text: String) -> Observable<Comment> {
        
        let interval = 60.0
        let announceText = " \(text) のTweetを取得中です"
        return Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .map { _ in
                return Announce(id: NSUUID().UUIDString, text: announceText)
            }
    }
}