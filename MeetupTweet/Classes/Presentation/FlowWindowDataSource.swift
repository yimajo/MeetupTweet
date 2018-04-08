//
//  FlowWindowDataSource.swift
//  MeetupTweet
//
//  Created by Yoshinori Imajo on 2018/04/08.
//  Copyright © 2018年 Yoshinori Imajo. All rights reserved.
//

import Foundation
import AppKit

protocol FlowWindowDataSource {
    func search(_ search: String, screen: NSScreen)
    func stop()
}
