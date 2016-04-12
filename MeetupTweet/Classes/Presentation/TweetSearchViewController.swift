//
//  TweetSearchViewController.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2016/04/10.
//  Copyright © 2016年 Yoshinori Imajo. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import OAuthSwift
import TwitterAPI

class TweetSearchViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var searchButton: NSButton!
        
    //    private var oauthSwift: OAuth1Swift?
    var window: NSWindow?
    let disposeBag = DisposeBag()
    var selectedScreenIndex = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tweetPresenter = CommentFlowPresenter()
        
        searchButton.rx_tap
            .subscribeNext { [unowned self] in
                if let screens = NSScreen.screens() {
                    let screen = screens[self.selectedScreenIndex]
                    tweetPresenter.searchTweet(self.searchField.stringValue, screen: screen)
                }
            }
            .addDisposableTo(disposeBag)
        
        stopButton.rx_tap
            .subscribeNext {
                tweetPresenter.stopSearch()
            }.addDisposableTo(disposeBag)
        
        let searchValid = searchField.rx_text
            .map{ text -> Bool in 0 < text.characters.count }
        
        searchValid
            .bindTo(searchButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter().rx_notification(NSApplicationDidChangeScreenParametersNotification)
            .subscribeNext { [unowned self] _ in
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.performSegueWithIdentifier("AuthSegueIdentifier", sender: nil)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
    }
}

extension TweetSearchViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return NSScreen.screens()?.count ?? 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.makeViewWithIdentifier("Cell", owner: self) as! NSTableCellView
        
        let screen = NSScreen.screens()![row]
        
        cell.textField!.stringValue = "Screen \(row) \(screen.frame)"
        return cell
    }
}

extension TweetSearchViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        selectedScreenIndex = tableView.selectedRow
        
        print(tableView.selectedRow)
        
        let screen = NSScreen.screens()![selectedScreenIndex]
        
        selectWindow(selectedScreenIndex, screen: screen)
    }
}

private extension TweetSearchViewController {
    
    func selectWindow(index: Int, screen: NSScreen) {
        
        self.window = makeWindow(screen)
        
        self.window?.alphaValue = 0.0
        
        NSAnimationContext.runAnimationGroup(
            { [weak self] context -> Void in
                if let window = self?.window {
                    context.duration = 0.25
                    window.animator().alphaValue = 1.0
                }
            }, completionHandler: {
                NSAnimationContext.runAnimationGroup(
                    { [weak self] context in
                        if let window = self?.window {
                            context.duration = 0.25
                            window.animator().alphaValue = 0.2
                        }
                    }, completionHandler: { [weak self] in
                        self?.window = nil
                    }
                )
            }
        )
    }
    
    
    func makeWindow(screen: NSScreen) -> NSWindow {
        
        let frame = NSRect(origin: CGPointZero, size: screen.frame.size)
        
        let window = NSWindow(contentRect: frame, styleMask: NSResizableWindowMask, backing: NSBackingStoreType.Buffered, defer: false, screen: screen)
        
        window.makeKeyAndOrderFront(nil)
        
        clearWindow(window)
        maxWindow(window, screen: screen)
        
        return window
    }
    
    func clearWindow(window: NSWindow) {
        window.styleMask = NSBorderlessWindowMask
        window.opaque = false
        window.hasShadow = false
        window.movable = true
        window.movableByWindowBackground = true
        window.releasedWhenClosed = false
        
        window.backgroundColor = NSColor.blackColor()
    }
    
    func maxWindow(window: NSWindow, screen: NSScreen) {
        let screenRect = screen.frame
        window.setFrame(screenRect, display: true)
        window.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
    }
}