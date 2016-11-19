//
//  TextField.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/10.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Cocoa

class TextField: NSTextField {
    
    fileprivate let commandKey = NSEventModifierFlags.command.rawValue
    fileprivate let commandShiftKey = NSEventModifierFlags.command.rawValue | NSEventModifierFlags.shift.rawValue
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEventType.keyDown {
            
            let keyModifier = event.modifierFlags.rawValue & NSEventModifierFlags.deviceIndependentFlagsMask.rawValue
            if keyModifier == commandKey {                
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to:nil, from:self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to:nil, from:self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to:nil, from:self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to:nil, from:self) { return true }
                default:
                    break
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}
