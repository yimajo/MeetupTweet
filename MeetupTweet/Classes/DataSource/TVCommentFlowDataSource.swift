//
//  TVCommentFlowDataSource.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/08/27.
//  Copyright © 2018年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import AppKit
import RxSwift
import TwitterAPI

class TVCommentFlowDataSource: FlowWindowDataSource {
    private(set) var subscription: Disposable?

    private let tweetSearchUseCase: TwitterStraemAPIUseCase
    private var window: NSWindow?
    private var commentView: MultiCommentView?
    private var containerView: ContentView?

    private var disposeBag: DisposeBag!
    private var comments: [String: (comment: CommentType, view: MultiCommentView)] = [:]
    private var waitingCommentsQueue: [CommentType] = []

    init(oauthClient: OAuthClient) {
        self.tweetSearchUseCase = TwitterStraemAPIUseCase(oauthClient: oauthClient)
    }

    func search(_ search: String, screen: NSScreen) {
        disposeBag = DisposeBag()
        refreshComments()
        window = makeTweetWindow(screen)
        containerView = makeContentView(from: window!)
        window!.contentView!.addSubview(containerView!)

        let tweetSearchSequence = tweetSearchUseCase.startStream(search)
            .observeOn(MainScheduler.instance)
            .startWith(Announce(search: search))
            .filter { !$0.message.hasPrefix("RT") }

        let announceSequence = AnnounceUseCase.intervalTextStream(search)
        let tweetSequence = Observable.of(tweetSearchSequence, announceSequence).merge()

        let interval = Observable.of(
            Observable<Int>.just(0),
            Observable<Int>.interval(3.0, scheduler: MainScheduler.instance)
        ).merge()

        subscription = interval.withLatestFrom(tweetSequence)
            .distinctUntilChanged { $0.identifier == $1.identifier }
            .subscribe(onNext: { [weak self] comment in
                self?.addComment(comment)
            })

        subscription?.disposed(by: disposeBag)
    }

    func stop() {
        window?.orderOut(nil)
        refreshComments()
        disposeBag = nil
    }
}


private extension TVCommentFlowDataSource {

    final class ContentView: NSView {
        override var isFlipped: Bool {
            return true
        }
    }

    func refreshComments() {
        tweetSearchUseCase.stopStream()
        subscription?.dispose()
        comments = [:]
    }

    func addComment(_ comment: CommentType) {
        commentView?.removeFromSuperview()
        commentView = makeMultiCommentView(comment)
        containerView?.addSubview(commentView!)

        commentView?.frame.origin.x = NSMidX(containerView!.frame) - NSMidX(commentView!.frame)
    }


    func makeContentView(from window: NSWindow) -> ContentView {
        let frame = NSRect(origin: CGPoint(x: 0, y: 0), size: window.frame.size)
        let view = ContentView(frame: frame)

        return view
    }

    func makeMultiCommentView(_ comment: CommentType) -> MultiCommentView {

        let commentView: MultiCommentView
        switch comment.type {
        case .tweet:
            commentView = MultiCommentView.makeView(comment.message, name: comment.name)
            if let url = comment.imageURL {
                URLSession.shared.rx.data(request: URLRequest(url: url))
                    .subscribe(onNext: { data in
                        DispatchQueue.main.async {
                            commentView.imageView.image = NSImage(data: data)
                        }
                    })
                    .disposed(by: disposeBag)
            }
        case .announce:
            commentView = MultiCommentView.makeView(comment.message, name: comment.name, fontColor: NSColor.red)
            commentView.imageView.image = NSApp.applicationIconImage
        }

        commentView.layoutSubtreeIfNeeded()

        commentView.frame.origin = CGPoint(x: 0, y: commentTopSpacing)
        commentView.frame.size.width = commentViewWidth
        commentView.changeFontSizeLarge()
        return commentView
    }

    func makeTweetWindow(_ screen: NSScreen) -> NSWindow {

        let size = CGSize(width: screen.frame.size.width, height: windowHeight)
        let origin = CGPoint(x: 0, y: 0)
        let frame = NSRect(origin: origin, size: size)

        let window = NSWindow(contentRect: frame, styleMask: .fullSizeContentView, backing: .buffered, defer: false, screen: screen)

        window.contentView!.wantsLayer = true
        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor(calibratedRed: 0.01, green: 0.2, blue: 1, alpha: 0.5)

        window.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
        window.makeKeyAndOrderFront(nil)

        return window
    }

    var commentTopSpacing: CGFloat {
        return 10
    }

    var velocity: CGFloat {
        return 5.0
    }

    var commentViewWidth: CGFloat {
        return window!.frame.size.width * 0.8
    }

    var windowHeight: CGFloat {
        return 150
    }
}
