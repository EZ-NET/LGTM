//
//  View.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import AppKit
class View: NSView {
    override func keyDown(theEvent: NSEvent) {
        Swift.print(theEvent.characters)
    }
}
