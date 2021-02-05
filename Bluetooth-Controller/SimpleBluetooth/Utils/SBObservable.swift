//
//  SBObservable.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation

public class SBObservable<Value> {
    typealias Event = (Value) -> Void
    private var observers: [AnyHashable: Event] = [:]
    
    /// Send a event and notify all observers.
    public func trigger(_ value: Value) {
        var invalidKyes: [SBWeakKey] = []
        for (key, event) in observers {
            if let weakKey = key as? SBWeakKey, weakKey.wasReleased {
                invalidKyes.append(weakKey)
            } else {
                event(value)
            }
        }
        invalidKyes.forEach { observers.removeValue(forKey: $0) }
    }
    
    /// Add observer, don't forget to invoke the `removeObserver` method when you don't need to listen to the data anymore.
    public func addObserver(_ key: AnyHashable, _ event: @escaping (Value) -> Void) {
        observers[key] = event
    }
    /// Remove observer
    public func removeObserver(_ key: AnyHashable) {
        observers[key] = nil
    }
    
    /// Add observer use `SBWeakKey`
    ///
    /// The key will be weakly reference to prevent circular references, and when the key is released, the corrosponding listener will also be automatically released.
    public func addObserver(_ key: SBWeakKey, _ event: @escaping (Value) -> Void) {
        observers[key] = event
    }
    /// Using `SBWeakKey` as a key to listen can be done without manually removing the observer,
    /// if the key is released, then the corresponding listener will also be released.
    public func removeObserver(_ key: SBWeakKey) {
        observers[key] = nil
    }
}
