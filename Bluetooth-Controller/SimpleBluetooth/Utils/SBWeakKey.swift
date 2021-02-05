//
//  SBWeakKey.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation

public class SBWeakKey: Hashable {
    private static var weakHashKeyPrefix = "sb_invalid_hash_flag"
    private static var weakHashKey: String { "\(weakHashKeyPrefix)_\(Date().timeIntervalSince1970)"}
    private weak var key: AnyObject?
    
    public static let invalidKey = SBWeakKey(nil)
    
    public var wasReleased: Bool { key == nil }
    
    public static func == (lhs: SBWeakKey, rhs: SBWeakKey) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        if let hashKey = key as? AnyHashable {
            hasher.combine(hashKey.hashValue)
        } else {
            hasher.combine(Self.weakHashKey)
        }
    }
        
    /// The `key` must be `AnyHashable` type else will occur crash.
    private init(_ key: AnyObject?) {
        if key != nil, !(key is AnyHashable) {
            fatalError("Init a SBWeakKey, but the \(String(describing: key)) is not a AnyHashable type")
        }
        self.key = key
    }
    
    public static func weak(_ key: AnyObject?) -> SBWeakKey {
        SBWeakKey(key)
    }
}
