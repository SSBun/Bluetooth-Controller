//
//  SBPeripheral.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation
import CoreBluetooth

public class SBPeripheral: NSObject {
    public enum Event {
        case updateName(name: String?)
        case read(RSSI: NSNumber)
        case didDiscoverServices(_ services: [SBService])
        case didDiscoverCharacteristics(_ characteristics: [SBCharacteristic], _ service: SBService)
        case didDiscoverDescriptors(_ descriptors: [SBDescriptor], _ characteristic: SBCharacteristic)
        
        case receiveData(_ characteristic: SBCharacteristic)
        
        case didConnect
        case failToConnect
        case didDisConnect
    }
    
    let peripheral: CBPeripheral
    public private(set) var advertisementData: [String: Any] = [:]
    public private(set) var RSSI: NSNumber? = nil
    
    public var name: String? { peripheral.name }
    public var id: UUID { peripheral.identifier }
    public var services: [SBService] { peripheral.services?.map { SBService($0) } ?? [] }
    
    public private(set) var isConnected = false
    
    
    public let observable = SBObservable<Event>()
        
    init(_ peripheral: CBPeripheral, _ advertisementData: [String: Any] = [:], _ RSSI: NSNumber? = nil) {
        self.peripheral = peripheral
        self.RSSI = RSSI
        self.advertisementData = advertisementData
        super.init()
        self.peripheral.delegate = self
        observeManager()
    }
        
    public override var description: String {
        return "name: \(peripheral.name ?? ""), uuid: \(RSSI?.intValue ?? 0), data: \(advertisementData)"
    }
    
    private func observeManager() {
        SBCentralManager.shared.observable.addObserver(.weak(self)) { state in
            if case let .didConnect(pp) = state, pp == self {
                self.trigger(.didConnect)
                self.isConnected = true
            } else if  case let .didDisConnect(pp) = state, pp == self {
                self.trigger(.didDisConnect)
                self.isConnected = false
            } else if case let .failToConnect(pp) = state, pp == self {
                self.trigger(.failToConnect)
                self.isConnected = false
            }
        }
    }
}

public extension SBPeripheral {
    private func trigger(_ event: Event) {
        DispatchQueue.main.async {
            self.observable.trigger(event)
        }
    }
}

public extension SBPeripheral {    
    func connect() {
        SBCentralManager.shared.connect(self)
    }
    
    func disconnect() {
        SBCentralManager.shared.disconnect(self)
    }
    
    func searchServices() {
        if (isConnected) {
            peripheral.discoverServices(nil)
        }
    }
    
    func refreshRSSI() {
        peripheral.readRSSI()
    }
}

extension SBPeripheral: CBPeripheralDelegate {
    // MARK: - Info
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        trigger(.updateName(name: name))
    }
        
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.RSSI = RSSI
        trigger(.read(RSSI: RSSI))
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        
    }
    
    // MARK: - Service
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            logError(error.localizedDescription)
            return
        }
        services.forEach { $0.searchCharacteristics() }
        trigger(.didDiscoverServices(services))
    }
        
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    
    // MARK: Data Read & Write
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
//        observable.trigger(.didDiscoverServices(services))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        trigger(.receiveData(.init(characteristic)))
    }

    // MARK: - Discover Characteristics
    @available(iOS 11.0, *)
    public func peripheral(_ peripheral: CBPeripheral, didpublic channel: CBL2CAPChannel?, error: Error?) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let sbService = searchService(service) else { return }
        
        trigger(.didDiscoverCharacteristics(sbService.characteristics, sbService))
        
        // To request the values and descriptors of all the characteristics.
        service.characteristics?.forEach { peripheral.readValue(for: $0) }
        service.characteristics?.forEach { peripheral.discoverDescriptors(for: $0) }
    }
    
    // MARK: - Discover Descriptors
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let sbCharacteristic = searchCharacteristic(characteristic) else { return }
        trigger(.didDiscoverDescriptors(sbCharacteristic.descriptors, sbCharacteristic))
        
        // Reading value for all descriptors.
        characteristic.descriptors?.forEach { peripheral.readValue(for: $0) }
    }
   
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
}

private extension SBPeripheral {
    func searchService(_ service: CBService) -> SBService? {
        services.filter({ $0.id == service.uuid.uuidString }).first
    }
    
    func searchCharacteristic(_ characteristic: CBCharacteristic) -> SBCharacteristic? {
        guard let service = searchService(characteristic.service) else { return nil }
        return service.characteristics.filter({ $0.id == characteristic.uuid.uuidString }).first
    }
}
