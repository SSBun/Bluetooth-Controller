//
//  SBDescriptor.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/25.
//

import CoreBluetooth

public struct SBDescriptor {
    private let descriptor: CBDescriptor
    public var characteristic: SBCharacteristic { .init(descriptor.characteristic) }
    
    public var id: String { descriptor.uuid.uuidString }
    public var characteristicId: String { descriptor.characteristic.uuid.uuidString }
    
    public var value: Any? { descriptor.value }
    public var name : String {
        guard let name = descriptor.uuid.name else {
            return "0x" + id
        }
        return name
    }
        
    init(_ descriptor: CBDescriptor) {
        self.descriptor = descriptor
    }
}
