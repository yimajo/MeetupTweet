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
    fileprivate let tweetSearchUseCase = TwitterStraemAPIUseCase()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var comments: [String: (comment: CommentType, view: CommentView)] = [:]
    fileprivate var commentViews: [CommentView?] = []
    fileprivate var window: NSWindow = NSWindow()
    
    func searchTweet(_ search: String, screen: NSScreen) {
        refreshComments()
        window = makeTweetWindow(screen)

        let startText = "Twiter Stream APIを\(search)で取得中です"
        
        let tweetStream = tweetSearchUseCase.startStream(search)
            .observeOn(MainScheduler.instance)
            .startWith(Announce(id: UUID().uuidString, text: startText))

        self.subscription = Observable.of(tweetStream, AnnounceUseCase.intervalTextStream(search))
            .merge()
            .subscribe(onNext: {  [unowned self] comment in
                self.addComment(comment)
            })
        
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
    
    func addComment(_ comment: CommentType) {
        let view = makeCommentView(comment)
        
        window.contentView?.addSubview(view)
        comments[comment.identifier()] = (comment: comment, view: view)

        startAnimationComment(comment, view: view)
    }
    
    func removeComment(_ comment: CommentType) {
        if let tweet = comments[comment.identifier()] {
            tweet.view.removeFromSuperview()
            comments[comment.identifier()] = nil
        }
    }
    
    func startAnimationComment(_ comment: CommentType, view: CommentView) {
        // TextFieldの移動開始
        let windowFrame = self.window.frame
        
        let v: CGFloat = 200.0

        let firstDuration = TimeInterval(view.frame.width / v)

        let len = windowFrame.width
        let secondDuration = TimeInterval(len / v)

        NSAnimationContext.runAnimationGroup(
            { context in
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                context.duration = firstDuration
//                view.animator().frame = CGRectOffset(view.frame, -view.frame.width, 0)
                view.animator().frame = view.frame.offsetBy(dx: -view.frame.width, dy: 0)

            }, completionHandler: { [unowned self] in

                for (index, v) in self.commentViews.enumerated() {
                    if v == view {
                        self.commentViews[index] = nil
                        break;
                    }
                }

                NSAnimationContext.runAnimationGroup(
                    { context in
                        context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                        context.duration = secondDuration
                        view.animator().frame = view.frame.offsetBy(dx: -len, dy: 0)
                        
                    }, completionHandler: {
                        self.removeComment(comment)
                    }
                )
            }
        )
    }
    
    func makeCommentView(_ comment: CommentType) -> CommentView {
        
        let commentView: CommentView
        switch comment.type() {
            case .tweet:
                commentView = CommentView.newCommentView(comment.message())
                if let url = comment.imageURL() {
                    URLSession.shared.rx.data(request: URLRequest(url: url))
                        .subscribe(onNext: { data in
                            commentView.imageView.image = NSImage.init(data: data)
                        }).addDisposableTo(disposeBag)
                }
            case .announce:
                commentView = CommentView.newCommentView(comment.message(), fontColor: NSColor.red)
                commentView.imageView.image = NSApp.applicationIconImage
        }
        
        var space = 0
        if commentViews.count == 0 {
            commentViews.append(commentView)
        } else {
            var add = false
            for (index, view) in commentViews.enumerated() {
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
        commentView.frame.origin = CGPoint(x: windowFrame.width, y: y)
        
        return commentView
    }
    
    func makeTweetWindow(_ screen: NSScreen) -> NSWindow {
        
        let menuHeight: CGFloat = 23.0
        
        let size = CGSize(width: screen.frame.size.width, height: screen.frame.size.height - menuHeight)
        let frame = NSRect(origin: CGPoint.zero, size: size)
        
        window = NSWindow(contentRect: frame, styleMask: NSResizableWindowMask, backing: .buffered, defer: false, screen: screen)

        window.styleMask = NSBorderlessWindowMask
        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor.clear

        window.level = Int(CGWindowLevelForKey(.maximumWindow))
        window.makeKeyAndOrderFront(nil)

        return window
    }
    
}
