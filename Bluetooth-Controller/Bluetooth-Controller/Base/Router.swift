//
//  NavigationTool.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit

enum Router {
    static var currentSelectedNavigationController: UINavigationController {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
        return rootVC.selectedViewController as! UINavigationController
    }
    
    static var topVC: UIViewController {
        currentSelectedNavigationController.topViewController!
    }
    
    static func push(_ vc: UIViewController, _ animated: Bool = true) {
        currentSelectedNavigationController.pushViewController(vc, animated: animated)
    }
    
    static func pop(_ animated: Bool = true) {
        currentSelectedNavigationController.popViewController(animated: animated)
    }
}

