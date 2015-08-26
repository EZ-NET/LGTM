//
//  ViewController.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import Cocoa
import Async

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    var monitor: AnyObject!
    var lgtm:Lgtm = Provider.sharedInstance.getRandomLgtm() {
        didSet {
            syncUI()
        }
    }
    private func syncUI() {
        textField.stringValue = lgtm.description
        textField.selectText(nil)
        let nsurl = NSURL(string: lgtm.url)
        if let nsurl = nsurl {
            imageView.image = NSImage(contentsOfURL: nsurl)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.preferredMaxLayoutWidth = 270
        syncUI()
        monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {[unowned self] e in
            let str:String = e.characters ?? ""
            print(e.keyCode)
            switch (str, e.keyCode) {
            case ("c", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyAction()
                }
            case (" ", _):
                let new = Provider.sharedInstance.getRandomLgtm()
                if new != self.lgtm {
                    self.lgtm = new
                }
            case (_, 36):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyAction()
                    // self.favoriteAction()
                }
            default:
                break
            }
            return e
        }
    }
}
extension ViewController {
    private func copyAction() {
        let gp = NSPasteboard.generalPasteboard()
        gp.declareTypes([NSStringPboardType], owner: nil)
        _ = gp.clearContents()
        self.textField.selectText(nil)
        if gp.writeObjects([self.lgtm.description]) {
            let a = NSAlert()
            a.messageText = "Copied !"
            a.runModal()
        }
    }
}

