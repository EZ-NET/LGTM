//
//  Lgtm.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//
import Darwin
import Alamofire

let LgtmFetchedNotification = "LgtmFetchedNotification"
class Provider {
    static let sharedInstance:Provider = Provider()
    var current = Lgtm() {
        didSet {
            let not = NSNotification(name: LgtmFetchedNotification, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(not)
        }
    }
    let arr = [
        Lgtm(url:"http://lgtm.in/p/yrdDOrCiq", tags:["kanna"]),
        Lgtm(url:"http://www.lancers.jp/magazine/wp-content/uploads/2013/03/m030041-580x320.jpg", tags:[]),
    ]
}
extension Provider {
    func getRandomLgtm(complete:(Lgtm, NSError?) -> ()) {
        let headers = ["Accept":"application/json"]
        Alamofire.request(.GET, "http://www.lgtm.in/g", headers:headers).responseJSON {req, res, result in
            if let res = res, json = result.value, url = json["actualImageUrl"] as? String where res.statusCode == 200 {
                complete(Lgtm(url: url), nil)
            } else {
            }
        }
    }
}

//import Realm
//import RealmSwift
//class RealmLgtm {
//    dynamic var url:String
//}
//extension Lgtm {
//    func saveToRealm() {
//        let realm = try! Realm()
//        realm.write {
//            realm.add(RealmLgtm(self))
//        }
//    }
//}
struct Lgtm {
    let url:String
    let tags:[String]
    init(url:String = "", tags:[String] = []) {
        self.url = url
        self.tags = tags
    }
}
extension Lgtm: CustomStringConvertible {
    var description:String {
        return "![LGTM](\(url))"
    }
}
extension Lgtm: Equatable {
}
func ==(lhs: Lgtm, rhs: Lgtm) -> Bool {
    return lhs.url == rhs.url
}
