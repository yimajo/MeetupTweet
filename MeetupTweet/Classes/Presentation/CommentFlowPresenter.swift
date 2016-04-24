//
//  TweetPresenter.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/03.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift


class CommentFlowPresenter {

    var subscription: Disposable?
    private let tweetSearchUseCase = TwitterStraemAPIUseCase()
    private let disposeBag = DisposeBag()
    private var comments: [String: (comment: CommentType, view: CommentView)] = [:]
    private var commentViews: [CommentView?] = []
    private var window: NSWindow = NSWindow()
    
    func searchTweet(search: String, screen: NSScreen) {
        refreshComments()
        window = makeTweetWindow(screen)

        let startText = "Twiter Stream APIを\(search)で取得中です"
        
        let tweetStream = tweetSearchUseCase.startStream(search)
            .observeOn(MainScheduler.instance)
            .startWith(Announce(id: NSUUID().UUIDString, text: startText))

        self.subscription = Observable.of(tweetStream, AnnounceUseCase.intervalTextStream(search))
            .merge()
            .subscribeNext { [unowned self] comment -> Void in
                self.addComment(comment)
            }
        
        self.subscription?.addDisposableTo(disposeBag)
    }
    
    func stopSearch() {
        window.orderOut(nil)
        refreshComments()
    }
}

private extension CommentFlowPresenter {

    func refreshComments() {
        tweetSearchUseCase.stopStream()
        subscription?.dispose()
        comments = [:]
        commentViews = []
    }
    
    func addComment(comment: CommentType) {
        let view = makeCommentView(comment)
        
        window.contentView?.addSubview(view)
        comments[comment.identifier()] = (comment: comment, view: view)

        startAnimationComment(comment, view: view)
    }
    
    func removeComment(comment: CommentType) {
        if let tweet = comments[comment.identifier()] {
            tweet.view.removeFromSuperview()
            comments[comment.identifier()] = nil
        }
    }
    
    func startAnimationComment(comment: CommentType, view: CommentView) {
        // TextFieldの移動開始
        let windowFrame = self.window.frame
        
        let v: CGFloat = 200.0

        let firstDuration = NSTimeInterval(view.frame.width / v)

        let len = windowFrame.width
        let secondDuration = NSTimeInterval(len / v)

        NSAnimationContext.runAnimationGroup(
            { context in
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                context.duration = firstDuration
                view.animator().frame = CGRectOffset(view.frame, -view.frame.width, 0)

            }, completionHandler: { [unowned self] in

                for (index, v) in self.commentViews.enumerate() {
                    if v == view {
                        self.commentViews[index] = nil
                        break;
                    }
                }

                NSAnimationContext.runAnimationGroup(
                    { context in
                        context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                        context.duration = secondDuration
                        view.animator().frame = CGRectOffset(view.frame, -len, 0)
                        
                    }, completionHandler: {
                        self.removeComment(comment)
                    }
                )
            }
        )
    }
    
    func makeCommentView(comment: CommentType) -> CommentView {
        
        let commentView: CommentView
        switch comment.type() {
            case .Tweet:
                commentView = CommentView.newCommentView(comment.message())
                if let url = comment.imageURL() {
                    NSURLSession.sharedSession().rx_data(NSURLRequest(URL: url))
                        .subscribeNext { data in
                            commentView.imageView.image = NSImage.init(data: data)
                        }.addDisposableTo(disposeBag)
                }
            case .Announce:
                commentView = CommentView.newCommentView(comment.message(), fontColor: NSColor.redColor())
                commentView.imageView.image = NSApp.applicationIconImage
        }
        
        var space = 0
        if commentViews.count == 0 {
            commentViews.append(commentView)
        } else {
            var add = false
            for (index, view) in commentViews.enumerate() {
                if view == nil {
                    commentViews[index] = commentView
                    space = index
                    add = true
                    break
                }
            }
            if !add {
                commentViews.append(commentView)
                space = commentViews.count
            }
        }
        
        commentView.layoutSubtreeIfNeeded()

        let windowFrame = self.window.frame
        let y = (windowFrame.height - commentView.frame.height) - (CGFloat(space) * commentView.frame.height)
        commentView.frame.origin = CGPointMake(windowFrame.width, y)
        
        return commentView
    }
    
    func makeTweetWindow(screen: NSScreen) -> NSWindow {
        
        let menuHeight: CGFloat = 23.0
        
        let size = CGSizeMake(screen.frame.size.width, screen.frame.size.height - menuHeight)
        let frame = NSRect(origin: CGPointZero, size: size)
        
        window = NSWindow(contentRect: frame, styleMask: NSResizableWindowMask, backing: .Buffered, defer: false, screen: screen)

        window.styleMask = NSBorderlessWindowMask
        window.opaque = false
        window.hasShadow = false
        window.movable = true
        window.movableByWindowBackground = true
        window.releasedWhenClosed = false
        window.backgroundColor = NSColor.clearColor()

        window.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
        window.makeKeyAndOrderFront(nil)

        return window
    }
    
}