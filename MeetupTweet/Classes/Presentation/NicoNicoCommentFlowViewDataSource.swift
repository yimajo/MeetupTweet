//
//  TweetPresenter.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/03.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import RxSwift
import AppKit

class NicoNicoCommentFlowWindowDataSource: FlowWindowDataSource {

    var subscription: Disposable?
    fileprivate let tweetSearchUseCase = TwitterStraemAPIUseCase()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var comments: [String: (comment: CommentType, view: CommentView)] = [:]
    fileprivate var commentViews: [CommentView?] = []
    fileprivate var window: NSWindow?
    
    func search(_ search: String, screen: NSScreen) {
        refreshComments()
        window = makeTweetWindow(screen)

        let tweetStream = tweetSearchUseCase.startStream(search)
            .observeOn(MainScheduler.instance)
            .startWith(Announce(search: search))

        self.subscription = Observable.of(tweetStream, AnnounceUseCase.intervalTextStream(search))
            .merge()
            .subscribe(onNext: {  [unowned self] comment in
                self.addComment(comment)
            })
        
        self.subscription?.addDisposableTo(disposeBag)
    }
    
    func stop() {
        window?.orderOut(nil)
        refreshComments()
    }
}

private extension NicoNicoCommentFlowWindowDataSource {

    func refreshComments() {
        tweetSearchUseCase.stopStream()
        subscription?.dispose()
        comments = [:]
        commentViews = []
    }
    
    func addComment(_ comment: CommentType) {
        guard let window = window else { return }

        let view = makeCommentView(comment, from: window)
        
        window.contentView?.addSubview(view)
        comments[comment.identifier] = (comment: comment, view: view)

        startAnimationComment(comment, view: view)
    }
    
    func removeComment(_ comment: CommentType) {
        if let tweet = comments[comment.identifier] {
            tweet.view.removeFromSuperview()
            comments[comment.identifier] = nil
        }
    }
    
    func startAnimationComment(_ comment: CommentType, view: CommentView) {
        guard let window = window else { return }

        // TextFieldの移動開始
        let windowFrame = window.frame
        
        let v: CGFloat = 200.0

        let firstDuration = TimeInterval(view.frame.width / v)

        let len = windowFrame.width
        let secondDuration = TimeInterval(len / v)

        NSAnimationContext.runAnimationGroup(
            { context in
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                context.duration = firstDuration
                view.animator().frame = view.frame.offsetBy(dx: -view.frame.width, dy: 0)

            }, completionHandler: { [weak self] in

                guard let `self` = self else { return }

                for (index, v) in self.commentViews.enumerated() {
                    if v == view {
                        self.commentViews[index] = nil
                        break;
                    }
                }

                NSAnimationContext.runAnimationGroup({ context in
                        context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                        context.duration = secondDuration
                        view.animator().frame = view.frame.offsetBy(dx: -len, dy: 0)
                        
                    }, completionHandler: { [weak self] in
                        self?.removeComment(comment)
                })
            }
        )
    }
    
    func makeCommentView(_ comment: CommentType, from window: NSWindow) -> CommentView {

        let commentView: CommentView
        switch comment.type {
            case .tweet:
                commentView = CommentView.newCommentView(comment.message)
                if let url = comment.imageURL {
                    URLSession.shared.rx.data(request: URLRequest(url: url))
                        .subscribe(onNext: { data in
                            DispatchQueue.main.async {
                                commentView.imageView.image = NSImage(data: data)
                            }
                        }).addDisposableTo(disposeBag)
                }
            case .announce:
                commentView = CommentView.newCommentView(comment.message, fontColor: NSColor.red)
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

        let windowFrame = window.frame
        let y = (windowFrame.height - commentView.frame.height) - (CGFloat(space) * commentView.frame.height)
        commentView.frame.origin = CGPoint(x: windowFrame.width, y: y)
        
        return commentView
    }
    
    func makeTweetWindow(_ screen: NSScreen) -> NSWindow {
        
        let menuHeight: CGFloat = 23.0
        
        let size = CGSize(width: screen.frame.size.width, height: screen.frame.size.height - menuHeight)
        let frame = NSRect(origin: CGPoint.zero, size: size)

        let window = NSWindow(contentRect: frame, styleMask: .resizable, backing: .buffered, defer: false, screen: screen)

        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor.clear

        window.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
        window.makeKeyAndOrderFront(nil)

        return window
    }
    
}
