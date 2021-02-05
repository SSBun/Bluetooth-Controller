//
//  PeripheralInfoViewController.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit
import QMUIKit
import SimpleBluetooth

class PeripheralInfoViewController: BaseViewController {
    private let peripheral: SBPeripheral
    
    private var services: [SBService] = []
    
    private lazy var infoView = config(QMUITableView(frame: .zero, style: .grouped)) {
        $0.delegate = self
        $0.dataSource = self
        $0.register(InfoCell.self, forCellReuseIdentifier: NSStringFromClass(InfoCell.self))
        $0.register(InfoHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(InfoHeader.self))
    }
        
    init(peripheral: SBPeripheral) {
        self.peripheral = peripheral
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        peripheral.observable.addObserver(.weak(self), { [weak self] in
            self?.observePeripheral($0)
        })
        peripheral.searchServices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.infoView.reloadData()
        }
    }
    
    private func setupUI() {
        title = peripheral.name ?? "unnamed"
        view.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
    
    private func observePeripheral(_ event: SBPeripheral.Event) {
        switch event {
        case .didDiscoverServices(let services):
            self.services = services
            self.infoView.reloadData()
        default:
            break
        }
    }
    
    deinit {
        peripheral.disconnect()
    }
}

extension PeripheralInfoViewController: QMUITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services[section].characteristics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(InfoCell.self)) as! InfoCell
        let service = services[indexPath.section]
        let characteristic = service.characteristics[indexPath.row]
        cell.title = characteristic.name
        if let stringValue = characteristic.stringValue {
            cell.subtitle = stringValue
        } else {
            cell.subtitle = characteristic.propertyNames.joined(separator: " ")            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(InfoHeader.self)) as! InfoHeader
        let service = services[section]
        headerView.title = service.name
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension PeripheralInfoViewController: QMUITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = services[indexPath.section]
        let characteristic = service.characteristics[indexPath.row]
        Router.push(CharacteristicInfoController(characteristic))
    }
}
