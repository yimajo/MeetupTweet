//
//  CommentView.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/03/20.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Cocoa

class CommentView: NSView {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var messageTextField: NSTextField!

    class var nibName: NSNib.Name { return NSNib.Name("CommentView") }
    
    class func newCommentView(_ message: String, fontColor: NSColor? = nil) -> CommentView {
        
        var topLevelObjects: NSArray? = []
        let nib = NSNib(nibNamed: nibName, bundle: Bundle.main)!
        nib.instantiate(withOwner: self, topLevelObjects: &topLevelObjects)
        
        var view: CommentView!
        
        for object: Any in topLevelObjects! {
            if let obj = object as? CommentView {
                view = obj
                break
            }
        }
        
        view.messageTextField.stringValue = message

        let attributes =  [
            NSAttributedStringKey.strokeColor: NSColor.black,
            NSAttributedStringKey.strokeWidth: NSNumber(value: -4.0 as Float),
            NSAttributedStringKey.foregroundColor: fontColor ?? NSColor.white,
        ]
        
        let attributedString = NSAttributedString(string: message, attributes: attributes)
        
        view.messageTextField.cell!.attributedStringValue = attributedString
        
        
        return view
    }
}
