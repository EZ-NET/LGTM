//
//  ViewController.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import Cocoa
import Async
enum ViewControllerType:String {
    case Lgtmin = "lgtm.in"
    case Favorites = "favorites"
}

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    var monitor: AnyObject!
    var lgtm:Lgtm? {
        didSet {
            syncUI()
        }
    }
    var type:ViewControllerType!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.title)
        textField.preferredMaxLayoutWidth = 270
        syncUI()
        configureEventMonitor()
        type = ViewControllerType(rawValue: self.title!)
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
                break
//                favButton.hidden = true
            }
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
                if let newlgtm = self.getLgtm() where newlgtm != self.lgtm {
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
    private func getLgtm() -> Lgtm? {
        switch type! {
        case .Lgtmin:
            return Provider.popRandomLgtm()
        case .Favorites:
            return Provider.popFavoriteLgtm()
        }
    }
}
