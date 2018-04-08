//
//  MultiCommentView.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/04/08.
//  Copyright © 2018年 Yoshinori Imajo. All rights reserved.
//

import AppKit

class MultiCommentView: NSView {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var messageTextField: NSTextField!

    class var nibName: NSNib.Name { return NSNib.Name("MultiCommentView") }

    class func makeView(_ message: String, fontColor: NSColor? = nil) -> MultiCommentView {

        var topLevelObjects: NSArray? = []
        let nib = NSNib(nibNamed: nibName, bundle: Bundle.main)!
        nib.instantiate(withOwner: self, topLevelObjects: &topLevelObjects)

        var view: MultiCommentView!

        for object: Any in topLevelObjects! {
            if let obj = object as? MultiCommentView {
                view = obj
                break
            }
        }

        view.messageTextField.stringValue = message

        return view
    }
}
