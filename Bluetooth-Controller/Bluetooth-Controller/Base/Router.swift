//
//  NavigationTool.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit
import SimpleBluetooth

enum Router {
    static var currentSelectedNavigationController: UINavigationController {
        let rootVC = UIApplication.shared.windows.first?.rootViewController as! UITabBarController
        return rootVC.selectedViewController as! UINavigationController
    }
    
    static var topVC: UIViewController {
        currentSelectedNavigationController.topViewController!
    }
    
    private static func push(_ vc: UIViewController, _ animated: Bool = true) {
        currentSelectedNavigationController.pushViewController(vc, animated: animated)
    }
    
    static func push(_ page: Route, _ animated: Bool = true) {
        switch page {
        case .characteristicInfo(let characteristic):
            push(CharacteristicInfoController(characteristic))
        case .peripheralInfo(let peripheral):
            push(PeripheralInfoViewController(peripheral: peripheral))
        }
    }
    
    static func pop(_ animated: Bool = true) {
        currentSelectedNavigationController.popViewController(animated: animated)
    }
}

extension Router {
    enum Route {
        case peripheralInfo(_ peripheral: SBPeripheral)
        case characteristicInfo(_ characteristic: SBCharacteristic)
    }
}

