//
//  TabViewController.swift
//  LGTM
//
//  Created by toshi0383 on 8/30/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import Cocoa

class TabViewController: NSTabViewController {

    private var monitor: AnyObject!
    override func viewDidAppear() {
        super.viewDidAppear()
        monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {[unowned self] e in
            let str:String = e.characters ?? ""
            switch (str, e.keyCode) {
            case ("1", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.tabView.selectTabViewItemAtIndex(0)
                    self.selectedTabViewItemIndex = 0
                }
            case ("2", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.tabView.selectTabViewItemAtIndex(1)
                    self.selectedTabViewItemIndex = 1
                }
            default:
                break
            }
            return e
        }
    }
    
}
