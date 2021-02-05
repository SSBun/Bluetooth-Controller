//
//  Data+Extension.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/26.
//

import Foundation

public extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
