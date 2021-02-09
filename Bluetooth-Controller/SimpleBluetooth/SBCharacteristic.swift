//
//  SBCharacteristic.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/25.
//

import CoreBluetooth

public struct SBCharacteristic {
    private let characteristic: CBCharacteristic
    
    public var service: SBService { .init(characteristic.service) }
    
    public var descriptors: [SBDescriptor] { characteristic.descriptors?.map { SBDescriptor($0) } ?? [] }
    public var id: String { characteristic.uuid.uuidString }
    public var serviceId: String { characteristic.service.uuid.uuidString }
    
    public var value: Data? { characteristic.value }
    public var isNotifying: Bool { characteristic.isNotifying }
    
    public var name : String {
        guard let name = characteristic.uuid.name else {
            return "0x" + id
        }
        return name
    }
    
    public var propertyNames: [String] { properties.names }
    public var canWrite: Bool { properties.contains(.write) || properties.contains(.writeWithoutResponse) || properties.contains(.authenticatedSignedWrites) }
    public var canNotify: Bool { properties.contains(.notify) || properties.contains(.notifyEncryptionRequired) }
    
    public var stringValue: String? {
        if let value = value {
            return String(data: value, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    var properties: CBCharacteristicProperties { characteristic.properties }
    
    
    init(_ characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
    
    func searchDescriptors() {
        characteristic.service.peripheral.discoverDescriptors(for: characteristic)
    }
    
    public func write(_ data: Data) {
        if canWrite {
            
            characteristic.service.peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    public func addNotify() {
        if canNotify {
            characteristic.service.peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    public func cancelNotify() {
        if isNotifying {
            characteristic.service.peripheral.setNotifyValue(false, for: characteristic)
        }
    }
}
