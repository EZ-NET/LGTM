//
//  Lgtm.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//
import Alamofire
import AppKit

class Provider {
    var fetching = false
    static let sharedInstance:Provider = Provider()
    var stackLimit = 20
    var stack:[Lgtm] = []
    init() {
        stack.appendContentsOf(getLgtmFromRealm())
    }
}
/// static method interfaces
extension Provider {
    class func favLgtm(lgtm:Lgtm) {
        sharedInstance.saveToRealm(lgtm)
    }
    class func getRandomLgtm() -> Lgtm? {
        return sharedInstance.getRandomLgtm()
    }
    class func fetchLgtmFromServer() {
        guard !sharedInstance.fetching else { return }
        sharedInstance.fetching = true
        sharedInstance.fetchLgtmFromServer()
    }
}
/// private interfaces
extension Provider {
    private func getRandomLgtm() -> Lgtm? {
        let lgtm = stack.popLast()
        fetchLgtmFromServer()
        return lgtm
    }
    /// fetch from lgtm.in/g to limit
    private func fetchLgtmFromServer() {
        fetchFromServer { [unowned self] in
            if self.stack.count < self.stackLimit {
                // fetch until stack.count reaches to limit
                self.fetchLgtmFromServer()
            } else {
                self.fetching = false
            }
        }
    }
    private func fetchFromServer(complete:()->()) {
        let headers = ["Accept":"application/json"]
        Alamofire.request(.GET, "http://www.lgtm.in/g", headers:headers).validate().responseJSON {req, res, result in
            switch result {
            case .Success:
            if let json = result.value, url = json["actualImageUrl"] as? String {
                Alamofire.request(.GET, url).validate(contentType: ["image/*"])
                    .responseData
                { req, res, result in
                    switch result {
                    case .Success(let value):
                    if let image = NSImage(data: value) {
                        let lgtm = Lgtm(url: url, image:image)
                        self.stack.append(lgtm)
                        complete()
                    }
                    case .Failure(_, let error):
                        print(error)
                    }
                }
            }
            case .Failure(_, let error):
                print(error)
                break
            }
        }
    }
}


import Realm
import RealmSwift
/// interact with Realm
extension Provider {
    private func getLgtmFromRealm() -> [Lgtm] {
        return []
    }
    private func saveToRealm(lgtm:Lgtm) {
        let data = RealmLgtm(lgtm: lgtm)
        let realm:Realm
        do {
            realm = try Realm()
        } catch {
            print(Realm.defaultPath)
            return
        }
        realm.write {
            realm.add(data, update: true)
        }
    }
}
class RealmLgtm : Object {
    dynamic var url:String = ""
    convenience init(lgtm:Lgtm) {
        self.init()
        self.url = lgtm.url
    }
    required init() {
        super.init()
    }
    override class func primaryKey() -> String? {
        return "url"
    }
}
struct Lgtm {
    let url:String
    let tags:[String]
    var image:NSImage
    init(url:String, image:NSImage, tags:[String] = []) {
        self.url = url
        self.image = image
        self.tags = tags
    }
}
extension Lgtm: WebFormatStringConvertible {}
extension Lgtm: CustomStringConvertible {
    var description:String {
        return url
    }
}
extension Lgtm: Equatable {}
func ==(lhs: Lgtm, rhs: Lgtm) -> Bool {
    return lhs.url == rhs.url
}
