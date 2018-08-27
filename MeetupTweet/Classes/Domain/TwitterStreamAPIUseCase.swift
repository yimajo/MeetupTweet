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
    
    fileprivate let disposeBag = DisposeBag()
    let streamEndpoint = "https://stream.twitter.com/1.1/statuses/filter.json"
    var streamingRequest: StreamingRequest?
    
    deinit {
        _ = self.streamingRequest?.stop()
    }
    
    func startStream(_ query: String) -> PublishSubject<CommentType> {
        
        if let streamingRequest = streamingRequest {
            _ = streamingRequest.stop()
        }
        
        let tweetStream = PublishSubject<CommentType>()

        streamingRequest = AppDelegate.sharedInstance.oauthClient!
            .streaming(streamEndpoint, parameters: ["track": query])
            .progress({ [unowned self] data -> Void in
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let tweet: Tweet = try decodeValue(json)
                    
                    tweetStream.onNext(tweet)

                } catch {
                    _ = self.streamingRequest?.stop()
                    tweetStream.onError(error)
                }
            })
            .completion({ (responseData: Data?, response: URLResponse?, error: NSError?) -> Void in
                if let error = error {

                    if error.domain == NSURLErrorDomain && error.code == -999 {
                        tweetStream.onCompleted()
                    } else {
                        tweetStream.onError(error)
                    }
                    return
                }
                if let data = responseData {
                    _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                }
                tweetStream.onCompleted()
            })
            .start()
        
        return tweetStream
    }
    
    func stopStream() {
        if let streamingRequest = streamingRequest {
            _ = streamingRequest.stop()
        }
    }
}
