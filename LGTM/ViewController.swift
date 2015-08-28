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
    var lgtm:Lgtm? {
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
        if let lgtm = lgtm {
            textField.stringValue = lgtm.markdown("LGTM")
            textField.selectText(nil)
            imageView.image = lgtm.image
        }
    }
    private func configureEventMonitor() {
         monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {[unowned self] e in
            let str:String = e.characters ?? ""
            print(e.keyCode)
            switch (str, e.keyCode) {
            case ("c", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyAction()
                }
            case (" ", _):
                if let newlgtm = Provider.getRandomLgtm() where newlgtm != self.lgtm {
                    self.lgtm = newlgtm
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
        if gp.writeObjects([self.textField.stringValue]) {
        }
    }
    private func favoriteAction() {
        if let lgtm = lgtm {
            Provider.favLgtm(lgtm)
        }
    }
}

