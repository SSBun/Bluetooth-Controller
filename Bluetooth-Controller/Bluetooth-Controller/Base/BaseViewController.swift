//
//  BaseViewController.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.pg.bg
    }
    
    deinit {
        print("\(Self.self) was released !!!")
    }
}
