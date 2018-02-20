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
        
    var window: NSWindow?
    let disposeBag = DisposeBag()
    var selectedScreenIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tweetPresenter = CommentFlowPresenter()
        
        searchButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if let screens = NSScreen.screens() {
                    let screen = screens[self.selectedScreenIndex]
                    tweetPresenter.searchTweet(self.searchField.stringValue, screen: screen)
                }
            })
            .addDisposableTo(disposeBag)
        
        stopButton.rx.tap
            .subscribe(onNext: {
                tweetPresenter.stopSearch()
            }).addDisposableTo(disposeBag)
        
        let searchValid = searchField.rx.text.orEmpty
            .map{ text -> Bool in 0 < text.count }
        
        searchValid
            .bind(to: searchButton.rx.isEnabled)
            .addDisposableTo(disposeBag)

        NotificationCenter.default.rx.notification(NSNotification.Name.NSApplicationDidChangeScreenParameters)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.performSegue(withIdentifier: "AuthSegueIdentifier", sender: nil)
    }
}

extension TweetSearchViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return NSScreen.screens()?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.make(withIdentifier: "Cell", owner: self) as! NSTableCellView
        
        let screen = NSScreen.screens()![row]
        
        cell.textField!.stringValue = "Screen \(row) \(screen.frame)"
        return cell
    }
}

extension TweetSearchViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        selectedScreenIndex = tableView.selectedRow
        
        print(tableView.selectedRow)
        
        let screen = NSScreen.screens()![selectedScreenIndex]
        
        selectWindow(selectedScreenIndex, screen: screen)
    }
}

private extension TweetSearchViewController {
    
    func selectWindow(_ index: Int, screen: NSScreen) {
        
        self.window = makeWindow(screen)
        
        self.window?.alphaValue = 0.0
        
        NSAnimationContext.runAnimationGroup(
            { [weak self] context in
                guard let window = self?.window else { return }

                context.duration = 0.25
                window.animator().alphaValue = 1.0

            }, completionHandler: {
                NSAnimationContext.runAnimationGroup(
                    { [weak self] context in
                        guard let window = self?.window else { return }

                        context.duration = 0.25
                        window.animator().alphaValue = 0.2

                    }, completionHandler: { [weak self] in
                        guard let window = self?.window else { return }

                        window.orderOut(nil)
                    }
                )
            }
        )
    }
    
    
    func makeWindow(_ screen: NSScreen) -> NSWindow {
        
        let frame = NSRect(origin: CGPoint.zero, size: screen.frame.size)
        
        let window = NSWindow(contentRect: frame, styleMask: NSResizableWindowMask, backing: NSBackingStoreType.buffered, defer: false, screen: screen)
        
        window.makeKeyAndOrderFront(nil)
        
        clearWindow(window)
        maxWindow(window, screen: screen)
        
        return window
    }
    
    func clearWindow(_ window: NSWindow) {
        window.styleMask = NSBorderlessWindowMask
        window.isOpaque = false
        window.hasShadow = false
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        
        window.backgroundColor = NSColor.black
    }
    
    func maxWindow(_ window: NSWindow, screen: NSScreen) {
        let screenRect = screen.frame
        window.setFrame(screenRect, display: true)
        window.level = Int(CGWindowLevelForKey(.maximumWindow))
    }
}
