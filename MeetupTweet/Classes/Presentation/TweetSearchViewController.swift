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

    let disposeBag = DisposeBag()
    var selectedScreenIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tweetPresenter = NicoNicoCommentFlowViewDataSource()
        
        searchButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let screen = NSScreen.screens[self.selectedScreenIndex]
                tweetPresenter.searchTweet(self.searchField.stringValue, screen: screen)
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

        NotificationCenter.default.rx.notification(NSApplication.didChangeScreenParametersNotification)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("AuthSegueIdentifier"), sender: nil)
    }
}

extension TweetSearchViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return NSScreen.screens.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor viewForTableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), owner: self) as! NSTableCellView
        
        let screen = NSScreen.screens[row]
        
        cell.textField!.stringValue = "Screen \(row) \(screen.frame)"
        return cell
    }
}

extension TweetSearchViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        selectedScreenIndex = tableView.selectedRow
        
        let screen = NSScreen.screens[selectedScreenIndex]
        SelectWindowUseCase(screen: screen).perform()
    }
}
