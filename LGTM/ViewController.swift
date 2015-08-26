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
    var loading = false {
        didSet {
            //show/hide HUD
        }
    }
    var monitor: AnyObject!
    var lgtm:Lgtm = Lgtm() {
        didSet {
            syncUI()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.preferredMaxLayoutWidth = 270
        syncUI()
        configureEventMonitor()
    }
}
extension ViewController {
    private func syncUI() {
        textField.stringValue = lgtm.description
        textField.selectText(nil)
        let nsurl = NSURL(string: lgtm.url)
        if let nsurl = nsurl {
            imageView.image = NSImage(contentsOfURL: nsurl)
        }
    }
    private func configureEventMonitor() {
         monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {[unowned self] e in
            guard !self.loading else { return e }
            let str:String = e.characters ?? ""
            print(e.keyCode)
            switch (str, e.keyCode) {
            case ("c", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyAction()
                }
            case (" ", _):
                self.loading = true
                Provider.sharedInstance.getRandomLgtm() { newlgtm, err in
                    self.loading = false
                    if newlgtm != self.lgtm {
                        self.lgtm = newlgtm
                    }
                }
            case (_, 36):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyAction()
                    self.favoriteAction()
                }
            default:
                break
            }
            return e
        }       
    }
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
    private func favoriteAction() {
//        lgtm.saveToRealm()
    }
}

