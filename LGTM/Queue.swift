//
//  Queue.swift
//  LGTM
//
//  Created by toshi0383 on 2015/08/29.
//  Copyright © 2015年 toshi0383. All rights reserved.
//

import Foundation

protocol QueueType {
    typealias Element
    mutating func enqueue(element:Element)
    mutating func dequeue() -> Element?
}
/// FIFO Queue
struct Queue<T>:QueueType {
    typealias Element = T
    var queue:[Element]
    var reverse:[Element]
    mutating func enqueue(element:Element) {
        queue.append(element)
    }
    mutating func dequeue() -> Element? {
        if reverse.count == 0 {
            reverse = queue.reverse()
            queue.removeAll(keepCapacity: true)
        }
        return reverse.popLast()
    }
}
extension Queue: CollectionType {
    var startIndex: Int {return 0}
    var endIndex: Int {
        return count == 0 ? 0 : count - 1
    }
    var count: Int {
        return queue.count + reverse.count
    }
    subscript(position:Int) -> Element {
        guard position <= endIndex else { fatalError("index out of bounds") }
        if position <= queue.endIndex {
            return queue[position]
        } else {
            return reverse[position - queue.endIndex]
        }
    }
}
extension Queue: ArrayLiteralConvertible {
    init(arrayLiteral elements: Element...) {
        reverse = elements.reverse()
        queue = []
    }
}
