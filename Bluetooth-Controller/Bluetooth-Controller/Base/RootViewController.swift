//
//  RootViewController.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildren()
    }
    
    private func setupChildren() {
        addChild(makeChildVC(SearchViewController.self, title: "Searching"))
        addChild(makeChildVC(SettingViewController.self, title: "Settings"))
    }
    
    private func makeChildVC(_ controllerType: BaseViewController.Type, title: String) -> BaseNavigationController {
        let vc = controllerType.init()
        vc.title = title
        let navigationController = BaseNavigationController(rootViewController: vc)
        navigationController.title = title
        return navigationController
    }
}
