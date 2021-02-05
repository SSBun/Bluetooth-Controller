//
//  CharacteristicInfoController.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/26.
//

import UIKit
import SimpleBluetooth
import QMUIKit

class CharacteristicInfoController: BaseViewController {
    
    let characteristic: SBCharacteristic
    
    private lazy var infoView = config(QMUITableView(frame: .zero, style: .grouped)) {
        $0.delegate = self
        $0.dataSource = self
        $0.register(InfoCell.self, forCellReuseIdentifier: NSStringFromClass(InfoCell.self))
        $0.register(InfoHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(InfoHeader.self))
    }
    
    init(_ characteristic: SBCharacteristic) {
        self.characteristic = characteristic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = characteristic.name
        view.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
    
}

extension CharacteristicInfoController: QMUITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return characteristic.propertyNames.count            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InfoCell.self)) as! InfoCell
        if indexPath.section == 0 {
            if let data = characteristic.value {
                cell.title = "0x" + data.hexEncodedString().uppercased()
            } else {
                cell.title = "No value"
            }
        } else if indexPath.section == 1 {
            cell.title = characteristic.propertyNames[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(InfoHeader.self)) as! InfoHeader
        if section == 0 {
            headerView.title = "Value"
        } else if section == 1 {
            headerView.title = "Properties"
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension CharacteristicInfoController: QMUITableViewDelegate {
    
}
