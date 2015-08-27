//
//  String+WebFormat.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/27.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import Foundation
import Swift

protocol WebFormatStringConvertible {
    func markdown(placeholder:Self) -> String
}
extension WebFormatStringConvertible {
    typealias T = CustomStringConvertible
    func markdown<T>(placeholder:T) -> String {
        return "![\(placeholder)](\(self))"
    }
}