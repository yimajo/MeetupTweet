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

    enum FlowStyle: Int {
        case youtube = 1 // View Tag
        case niconico
        case tv
    }

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var searchButton: NSButton!

    let disposeBag = DisposeBag()
    var selectedScreenIndex = 0
    var flowStyle = FlowStyle.youtube

    private var commentFlowWindowDataSource: FlowWindowDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.commentFlowWindowDataSource?.stop()
                self.commentFlowWindowDataSource = nil

                self.search()
            })
            .disposed(by: disposeBag)

        stopButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.commentFlowWindowDataSource?.stop()
                self.commentFlowWindowDataSource = nil
            })
            .disposed(by: disposeBag)

        let searchValid = searchField.rx.text.orEmpty
            .map{ text -> Bool in 0 < text.count }
        
        searchValid
            .bind(to: searchButton.rx.isEnabled)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(NSApplication.didChangeScreenParametersNotification)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        AppDelegate.sharedInstance.applyToken()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        if AppDelegate.sharedInstance.oauthClient == nil {
            performSegue(withIdentifier: NSStoryboardSegue.Identifier("AuthSegueIdentifier"), sender: nil)
        }
    }
}

extension TweetSearchViewController {

    @IBAction func touchRadioButton(_ matrix: NSMatrix) {

        guard let flowStyle = FlowStyle(rawValue: matrix.selectedCell()!.tag) else {
            return
        }

        self.flowStyle = flowStyle
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

private extension TweetSearchViewController {
    func search() {
        guard 0 < searchField.stringValue.count else { return }

        switch flowStyle {
        case .youtube:
            commentFlowWindowDataSource = YouTubeCommentFlowWindowDataSource()
        case .niconico:
            commentFlowWindowDataSource = NicoNicoCommentFlowWindowDataSource()
        case .tv:
            commentFlowWindowDataSource = TVCommentFlowDataSource()
        }

        let screen = NSScreen.screens[selectedScreenIndex]
        commentFlowWindowDataSource!.search(searchField.stringValue, screen: screen)
    }
}
