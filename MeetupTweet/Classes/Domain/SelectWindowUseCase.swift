//
//  SelectWindowUseCase.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/04/07.
//  Copyright © 2018年 Yoshinori Imajo. All rights reserved.
//

import AppKit

struct SelectWindowUseCase {

    private let window: NSWindow

    init(screen: NSScreen) {
        window = type(of: self).makeWindow(screen)
    }

    func perform() {
        selectWindow()
    }
}

private extension SelectWindowUseCase {

    func selectWindow() {

        window.alphaValue = 0.0
        NSAnimationContext.runAnimationGroup({ context in

            context.duration = 0.25
            self.window.animator().alphaValue = 1.0

        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ context in

                context.duration = 0.25
                self.window.animator().alphaValue = 0.2

            }, completionHandler: {
                self.window.orderOut(nil)
            })
        })
    }

    static func makeWindow(_ screen: NSScreen) -> NSWindow {

        let frame = NSRect(origin: CGPoint.zero, size: screen.frame.size)

        let window = NSWindow(contentRect: frame, styleMask: NSWindow.StyleMask.resizable, backing: NSWindow.BackingStoreType.buffered, defer: false, screen: screen)

        window.makeKeyAndOrderFront(nil)

        setupClearWindow(window)
        setupMaxWindow(window, screen: screen)

        return window
    }

    static func setupClearWindow(_ window: NSWindow) {
        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false

        window.backgroundColor = NSColor.black
    }

    static func setupMaxWindow(_ window: NSWindow, screen: NSScreen) {
        let screenRect = screen.frame
        window.setFrame(screenRect, display: true)
        window.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
    }
}
