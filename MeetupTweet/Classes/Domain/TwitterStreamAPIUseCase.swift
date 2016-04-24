//
//  TweetSearchUseCase.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/03.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import OAuthSwift
import Himotoki
import RxSwift
import TwitterAPI

class TwitterStraemAPIUseCase {
    
    private let disposeBag = DisposeBag()
    let streamEndpoint = "https://stream.twitter.com/1.1/statuses/filter.json"
    var streamingRequest: StreamingRequest?
    
    deinit {
        self.streamingRequest?.stop()
    }
    
    func startStream(query: String) -> PublishSubject<CommentType> {
        
        if let streamingRequest = streamingRequest {
            streamingRequest.stop()
        }
        
        let tweetStream = PublishSubject<CommentType>()
        
        streamingRequest = AppDelegate.sharedInstance.oauthClient!
            .streaming(streamEndpoint, parameters: ["track": query])
            .progress({ [unowned self] data -> Void in
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    let tweet: Tweet = try decodeValue(json)
                    tweetStream.onNext(tweet)

                } catch {
                    self.streamingRequest?.stop()
                    tweetStream.onError(error)
                }
            })
            .completion({ (responseData: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if let error = error {

                    if error.domain == NSURLErrorDomain && error.code == -999 {
                        tweetStream.onCompleted()
                    } else {
                        tweetStream.onError(error)
                    }
                    return
                }
                if let data = responseData {
                    let out = NSString(data: data, encoding:NSUTF8StringEncoding)
                    print(out)
                }
                tweetStream.onCompleted()
            })
            .start()
        
        return tweetStream
    }
    
    func stopStream() {
        if let streamingRequest = streamingRequest {
            streamingRequest.stop()
        }
    }
}