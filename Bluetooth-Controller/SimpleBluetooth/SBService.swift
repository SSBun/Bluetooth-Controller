//
//  SBService.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import CoreBluetooth

public struct SBService {
    private let service: CBService
    
    public var id: String { service.uuid.uuidString }
    public var name : String {
        guard let name = service.uuid.name else {
            return "0x" + id
        }
        return name
    }
    
    public var characteristics: [SBCharacteristic] { service.characteristics?.map { SBCharacteristic($0) } ?? []}
    
    init(_ service: CBService) {
        self.service = service
    }
    
    func searchCharacteristics() {
        service.peripheral.discoverCharacteristics(nil, for: service)
    }
}
