//
//  ViewController.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import AppKit
import Async
enum ViewControllerType:String {
    case Lgtmin = "lgtm.in"
    case Favorites = "favorites"
}

class ViewController: NSViewController {

    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var loveButton: NSButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    private var monitor: AnyObject!
    private var lgtm:Lgtm? {
        didSet {
            syncUI()
        }
    }
    internal var type:ViewControllerType!
    override func viewDidLoad() {
        super.viewDidLoad()
        /// textField
        textField.preferredMaxLayoutWidth = 270
        /// imageView
        imageView.animates = true
        imageView.imageScaling = NSImageScaling.ScaleProportionallyUpOrDown
        imageView.canDrawSubviewsIntoLayer = true
        /// syncUI
        syncUI()
        /// button actions
        type = ViewControllerType(rawValue: self.title!)
        copyButton.action = "copyAction"
        copyButton.target = self
        switch type! {
        case .Lgtmin:
            loveButton.action = "favoriteAction"
            loveButton.target = self
        case .Favorites:
            break
        }
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSEvent.removeMonitor(monitor)
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        configureEventMonitor()
    }
}
extension ViewController {
    private func syncUI() {
        if let lgtm = lgtm {
            textField.stringValue = lgtm.markdown("LGTM")
            textField.selectText(nil)
            imageView.image = lgtm.image
            switch type! {
            case .Lgtmin:
                break
            case .Favorites:
//                loveButton.hidden = true
                break
            }
        }
    }
    private func configureEventMonitor() {
        monitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) {[unowned self] e in
            let str:String = e.characters ?? ""
            switch (str, e.keyCode) {
            case ("c", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    self.copyButton.performClick(self.copyButton)
                }
            case (" ", 49):
                if let newlgtm = self.getLgtm() where newlgtm != self.lgtm {
                    self.lgtm = newlgtm
                }
            case ("s", _):
                if e.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                    if self.type == .Lgtmin {
                        self.loveButton.performClick(self.loveButton)
                    }
                }
            default:
                break
            }
            return e
        }       
    }
    internal func copyAction() {
        let gp = NSPasteboard.generalPasteboard()
        gp.declareTypes([NSStringPboardType], owner: nil)
        _ = gp.clearContents()
        self.textField.selectText(nil)
        if gp.writeObjects([self.textField.stringValue]) { }
    }
    internal func favoriteAction() {
        copyAction()
        if let lgtm = lgtm {
            Provider.favLgtm(lgtm)
        }
    }
    private func getLgtm() -> Lgtm? {
        switch type! {
        case .Lgtmin:
            return Provider.popRandomLgtm()
        case .Favorites:
            return Provider.popFavoriteLgtm()
        }
    }
}
