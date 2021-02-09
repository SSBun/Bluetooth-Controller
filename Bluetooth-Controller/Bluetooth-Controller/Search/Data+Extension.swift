//
//  Data+Extension.swift
//  Bluetooth-Controller
//
//  Created by Rebecca on 2021/2/8.
//

import Foundation

extension Data {
    var stringValue: String? { String(data: self, encoding: .utf8) }
}
