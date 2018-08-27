//
//  YouTubeCommentFlowWindowDataSource.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/04/07.
//  Copyright © 2018年 Yoshinori Imajo. All rights reserved.
//

import AppKit
import RxSwift

class YouTubeCommentFlowWindowDataSource: FlowWindowDataSource {

    var subscription: Disposable?

    private let tweetSearchUseCase = TwitterStraemAPIUseCase()
    private var window: NSWindow?
    private var stackView: NSStackView!
    private var disposeBag: DisposeBag!
    private var comments: [String: (comment: CommentType, view: MultiCommentView)] = [:]
    private var waitingCommentsQueue: [CommentType] = []

    func search(_ search: String, screen: NSScreen) {
        disposeBag = DisposeBag()
        refreshComments()
        window = makeTweetWindow(screen)
        stackView = makeStackView(from: window!)
        window!.contentView!.addSubview(stackView)

        let tweetStream = tweetSearchUseCase.startStream(search)
            .observeOn(MainScheduler.instance)
            .startWith(Announce(search: search))

        subscription = Observable.of(tweetStream, AnnounceUseCase.intervalTextStream(search))
            .merge()
            .subscribe(onNext: { [unowned self] comment in
                self.addComment(comment)
            })

        subscription?.addDisposableTo(disposeBag)
    }

    func stop() {
        window?.orderOut(nil)
        refreshComments()
        disposeBag = nil
    }
}

private extension YouTubeCommentFlowWindowDataSource {

    func refreshComments() {
        tweetSearchUseCase.stopStream()
        subscription?.dispose()
        comments = [:]
    }

    func addComment(_ comment: CommentType) {
        let view = self.makeMultiCommentView(comment)
        stackView.addView(view, in: .bottom)
        removeCommentIfOverHeight()
    }

    func removeCommentIfOverHeight() {

        if stackView.frame.size.height < stackViewSubviewsHeight {
            for view in stackView.arrangedSubviews {

                if stackView.frame.size.height < stackViewSubviewsHeight {
                    stackView.removeView(view)
                }
            }
        }
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
                    }).addDisposableTo(disposeBag)
            }
        case .announce:
            commentView = MultiCommentView.makeView(comment.message, name: comment.name, fontColor: NSColor.red)
            commentView.imageView.image = NSApp.applicationIconImage
        }

        commentView.layoutSubtreeIfNeeded()

        commentView.frame.origin = CGPoint(x: 0, y: 0)

        return commentView
    }

    func makeTweetWindow(_ screen: NSScreen) -> NSWindow {

        let menuHeight: CGFloat = 23.0

        let size = CGSize(width: windowWidth, height: screen.frame.size.height - menuHeight)
        let origin = CGPoint(x: calculateOriginX(screenWidth: screen.frame.size.width), y: 0)
        let frame = NSRect(origin: origin, size: size)

        let window = NSWindow(contentRect: frame, styleMask: .fullSizeContentView, backing: .buffered, defer: false, screen: screen)

        window.contentView!.wantsLayer = true
        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = NSColor.green.withAlphaComponent(0.2)

        window.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
        window.makeKeyAndOrderFront(nil)

        return window
    }

    func makeStackView(from window: NSWindow) -> NSStackView {
        let view = NSStackView(frame: NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height))
        view.orientation = .vertical
        view.alignment = .left
        view.spacing = spacing

        return view
    }

    var stackViewSubviewsHeight: CGFloat {
        return stackView.arrangedSubviews.reduce(0) { (total, view) -> CGFloat in
            total + view.frame.size.height + self.spacing
        }
    }

    var spacing: CGFloat {
        return 30
    }

    var velocity: CGFloat {
        return 5.0
    }

    var windowWidth: CGFloat {
        return 400
    }

    func calculateOriginX(screenWidth: CGFloat) -> CGFloat {
        return screenWidth - windowWidth
    }
}
