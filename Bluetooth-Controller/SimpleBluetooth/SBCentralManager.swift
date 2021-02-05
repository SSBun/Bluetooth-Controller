//
//  SBCentralManager.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation
import CoreBluetooth

public class SBCentralManager: NSObject {
    public enum Event {
        case stateChanged(_ state: CBManagerState)
        case findNewPeripheral(_ peripheral: SBPeripheral)
        case didConnect(_ peripheral: SBPeripheral)
        case failToConnect(_ peripheral: SBPeripheral)
        case didDisConnect(_ peripheral: SBPeripheral)
    }
            
    // MARK: - Public Properties
    public static let shared = SBCentralManager()
    
    public private(set) var state: CBManagerState = .unknown
        
    // MARK: - Private Properties
    private var centralManager: CBCentralManager?
    private let centralQueue = DispatchQueue(label: "SB_CENTRAL_QUEUE")
    private static var restoreIdentifier: String = "SBManager_restoreIdentifier"
    private var waitSearch: Bool = false
    
    public let observable = SBObservable<Event>()
    public let peripheralList = SBSearchList()
      
    public static func config(_ restoreIdentifier: String) {
        self.restoreIdentifier = restoreIdentifier
    }
    
    // The timer is used to refresh the RSSI of all peripherals at regular intervals
    private var refreshRSSITimer: Timer?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: Self.restoreIdentifier])
    }
}

public extension SBCentralManager {
    private func trigger(_ event: Event) {
        DispatchQueue.main.async {
            self.observable.trigger(event)
        }
    }
}

public extension SBCentralManager {
    func search() {
        if (state == .poweredOn) {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        } else {
            waitSearch = true
        }
    }
    
    func connect(_ peripheral: SBPeripheral) {
        centralManager?.connect(peripheral.peripheral, options: nil)
    }
    
    func disconnect( _ peripheral: SBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral.peripheral)
    }
    
    /// Refresh RSSI of all peripherals at regular intervals
    func beginRefreshRSSI(_ interval: TimeInterval = 3) {
        guard refreshRSSITimer == nil else { return }
        refreshRSSITimer = Timer(fire: .init(), interval: interval, repeats: true, block: { [weak self] _ in
            self?.peripheralList.peripherals.forEach { $0.refreshRSSI() }
        })
        RunLoop.main.add(refreshRSSITimer!, forMode: .common)
    }
    
    func stopRefreshRSSI() {
        refreshRSSITimer?.invalidate()
        refreshRSSITimer = nil
    }
}

extension SBCentralManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        state = central.state
        trigger(.stateChanged(state))
        print("centralManagerDidUpdateState: \(central.state.rawValue)")
        if state == .poweredOn && waitSearch {
            search()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newPeripheral = SBPeripheral(peripheral, advertisementData, RSSI)
        peripheralList.append(newPeripheral)
        trigger(.findNewPeripheral(newPeripheral))
    }
           
    public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print("didUpdateANCSAuthorizationFor")
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        trigger(.didConnect(peripheralList.convert(peripheral)))
        print("didConnectPeripheral")
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        trigger(.didDisConnect(peripheralList.convert(peripheral)))
        print("didDisconnectPeripheral")
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        trigger(.failToConnect(peripheralList.convert(peripheral)))
        print("didFailToConnect")
    }
    
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connectionEventDidOccur")
    }
}
