//
//  SBSearchList.swift
//  SimpleBluetooth
//
//  Created by caishilin on 2021/1/24.
//

import Foundation
import CoreBluetooth

public class SBSearchList {
    public private(set) var peripherals: [SBPeripheral] = []
    public var count: Int { peripherals.count }
    
    public func append(_ peripheral: SBPeripheral) {
        var searchedIndex: Int = -1
        for (index, item) in peripherals.enumerated() {
            if item.id == peripheral.id {
                searchedIndex = index
            }
        }
        if searchedIndex != -1 {
            peripherals[searchedIndex] = peripheral            
            return
        }
        peripherals.append(peripheral)
    }
    
    public func filter() -> [SBPeripheral] {
        return []
    }
    
    func convert(_ peripheral: CBPeripheral) -> SBPeripheral {
        for item in peripherals {
            if item.id == peripheral.identifier {
                return item
            }
        }
        let newPeripheral = SBPeripheral(peripheral)
        append(newPeripheral)
        return newPeripheral
    }
}
