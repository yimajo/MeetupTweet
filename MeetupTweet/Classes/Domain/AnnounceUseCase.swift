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
    
    class func intervalTextStream(_ text: String) -> Observable<CommentType> {
        
        let interval = 60.0
        return Observable<Int>
            .interval(interval, scheduler: MainScheduler.instance)
            .map { _ in
                return Announce(search: text)
            }
    }
}
