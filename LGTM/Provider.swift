//
//  Lgtm.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/26.
//  Copyright © 2015年 toshi0383. All rights reserved.
//
import Darwin
class Provider {
    static let sharedInstance:Provider = Provider()
    let arr = [
        Lgtm(url:"http://lgtm.in/p/yrdDOrCiq", tags:["kanna"]),
        Lgtm(url:"http://www.lancers.jp/magazine/wp-content/uploads/2013/03/m030041-580x320.jpg", tags:[]),
    ]
    func getRandomLgtm() -> Lgtm {
        let r = Int(arc4random_uniform(10000))
        return arr[r % arr.count]
    }
}

struct Lgtm {
    let url:String
    let tags:[String]
    init(url:String, tags:[String] = []) {
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
