//
//  BTNamespace.swift
//  Bluetooth-Controller
//
//  Created by Rebecca on 2021/2/9.
//

import Foundation

struct PhageWrapper<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol PhageCompatible: AnyObject {}
protocol PhageCompatibleValue {}

extension PhageCompatible {
    var pg: PhageWrapper<Self> { .init(self) }
    static var pg: PhageWrapper<Self.Type> { .init(Self.self) }
}

extension NSObject: PhageCompatible {}
