//
//  AppDelegate.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Provider.fetchLgtmFromServer()
        Provider.fetchLgtmFromRealm()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

