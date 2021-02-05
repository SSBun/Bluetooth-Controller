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

        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("\(Self.self) was released !!!")
    }
}
