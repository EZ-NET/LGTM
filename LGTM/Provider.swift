//
//  Lgtm.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//
import Alamofire
import AppKit
import Async

class Provider {
    private var fetching = false
    private var fetchingRealm = false
    private static let sharedInstance:Provider = Provider()
    private var stackLimit = 20
    private var stack:Queue<Lgtm> = []
    private var favStack:Queue<Lgtm> = []
    private var history:Queue<String> = []
}
/// static method interfaces
extension Provider {
    class func favLgtm(lgtm:Lgtm) {
        sharedInstance.saveToRealm(lgtm)
    }
    class func popRandomLgtm() -> Lgtm? {
        return sharedInstance.popRandomLgtm()
    }
    class func popFavoriteLgtm() -> Lgtm? {
        return sharedInstance.popFavoriteLgtm()
    }
    class func fetchLgtmFromServer() {
        guard !sharedInstance.fetching else { return }
        sharedInstance.fetching = true
        sharedInstance.fetchLgtmFromServer()
    }
    class func fetchLgtmFromRealm() {
        guard !sharedInstance.fetchingRealm else { return }
        sharedInstance.fetchingRealm = true
        sharedInstance.fetchFromRealm()
    }
}
/// private interfaces
extension Provider {
    private func popRandomLgtm() -> Lgtm? {
        let lgtm = stack.dequeue()
        if let lgtm = lgtm {
            if history.count >= 200 {
                history.dequeue()
            }
            history.enqueue(lgtm.url)
        }
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
    typealias FetchComplete = ()->()
    private func fetchFromServer(complete:FetchComplete) {
        let headers = ["Accept":"application/json"]
        Alamofire.request(.GET, "http://www.lgtm.in/g", headers:headers).validate().responseJSON {req, res, result in
            switch result {
            case .Success:
            if let json = result.value, url = json["actualImageUrl"] as? String {
                if self.history.contains(url) {
                    return
                }
                self.fetchImage(url) { image in
                    let lgtm = Lgtm(url: url, image:image)
                    self.stack.enqueue(lgtm)
                    complete()
                }
            }
            case .Failure(_, let error):
                print(error)
                break
            }
        }
    }
    typealias FetchImageComplete = NSImage->()
    private func fetchImage(url:String, complete:FetchImageComplete) {
        Alamofire.request(.GET, url).validate(contentType: ["image/*"])
            .responseData
        { req, res, result in
            switch result {
            case .Success(let value):
            if let image = NSImage(data: value) {
                complete(image)
            }
            case .Failure(_, let error):
                print(error)
            }
        }
    }
}


import RealmSwift
/// interact with Realm
extension Provider {
    private func popFavoriteLgtm() -> Lgtm? {
        let lgtm = favStack.dequeue()
        fetchFromRealm()
        return lgtm
    }
    private func fetchFromRealm() {
        let realm = getRealm()
        let results = realm.objects(RealmLgtm).filter {e in true} as [RealmLgtm]
        let urls = results.map{$0.url}
        let targetUrls:[String]
        if urls.count > stackLimit {
            targetUrls = [] + urls[0...(stackLimit - 1)]
        } else {
            targetUrls = urls
        }
        for url in targetUrls {
            fetchImage(url) { [unowned self] image in
                let lgtm = Lgtm(url: url, image:image)
                self.favStack.enqueue(lgtm)
                if self.favStack.count >= self.stackLimit {
                    self.fetchingRealm = false
                }
            }
        }
    }
    private func saveToRealm(lgtm:Lgtm) {
        let data = RealmLgtm(lgtm: lgtm)
        let realm = getRealm()
        realm.write {
            realm.add(data, update: true)
        }
    }
}
extension Provider {
    private func getRealm() -> Realm {
        let realm:Realm
        do {
            realm = try Realm()
        } catch {
            print(error)
            print(Realm.Configuration.defaultConfiguration.path)
            fatalError()
        }
        return realm
    }
}
class RealmLgtm : Object {
    dynamic var url:String = ""
    convenience init(lgtm:Lgtm) {
        self.init()
        self.url = lgtm.url
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
