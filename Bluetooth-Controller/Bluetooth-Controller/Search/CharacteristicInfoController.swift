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
    
    private let maxCountOfDisplayedValues = 10
    
    private var peripheral: SBPeripheral { characteristic.service.peripheral }
    private var values: [Data] = []
    
    private lazy var infoView = config(QMUITableView(frame: .zero, style: .grouped)) {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.register(InfoCell.self, forCellReuseIdentifier: NSStringFromClass(InfoCell.self))
        $0.register(InfoHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(InfoHeader.self))
        $0.register(WriteCell.self, forCellReuseIdentifier: NSStringFromClass(WriteCell.self))
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
        addObserver()
    }
    
    private func setupUI() {
        title = characteristic.name
        view.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
    
    private func addObserver() {
        if characteristic.canNotify {
            characteristic.addNotify()
        }
        peripheral.observable.addObserver(.weak(self)) { [unowned self] event in
            if case .receiveData(let characteristic) = event {
                if characteristic.id == self.characteristic.id {
                    self.receiveNewValue()
                }
            }
        }
    }
    
    private func receiveNewValue() {
        guard let value = characteristic.value else { return }
        print("receive data: \(value.stringValue ?? value.hexEncodedString())")
        values.append(value)
        infoView.reloadSections(.init(integer: 1), with: .automatic)
    }
    
    deinit {
        if characteristic.canNotify {
            characteristic.cancelNotify()
        }
    }
    
}

extension CharacteristicInfoController: QMUITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if characteristic.canWrite {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return characteristic.propertyNames.count
        } else if section == 1 {
            return min(maxCountOfDisplayedValues, values.count)
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InfoCell.self)) as! InfoCell
            cell.title = characteristic.propertyNames[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InfoCell.self)) as! InfoCell
            let value = values.reversed()[indexPath.row]
            cell.title = "\(value.stringValue ?? value.hexEncodedString().uppercased())"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(WriteCell.self)) as! WriteCell
            cell.characteristic = characteristic
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(InfoHeader.self)) as! InfoHeader
        if section == 0 {
            headerView.title = "Properties"
        } else if section == 1 {
            headerView.title = "Value"
        } else if section == 2 {
            headerView.title = "Write Value"
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
