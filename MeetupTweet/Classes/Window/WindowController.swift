//
//  WindowController.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/11.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import AppKit

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window!.delegate = self
    }
}

extension WindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(NSApp?.keyWindow!)
    }
}
