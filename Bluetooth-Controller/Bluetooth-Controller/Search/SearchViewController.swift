//
//  SearchViewController.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit
import SimpleBluetooth
import QMUIKit

class SearchViewController: BaseViewController {
    private lazy var listView: QMUITableView = {
        let view = QMUITableView()
        view.dataSource = self
        view.delegate = self
        view.register(PeripheralSearchCell.self, forCellReuseIdentifier: NSStringFromClass(PeripheralSearchCell.self))
        return view
    }()
    
    private var peripherals: [SBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        SBCentralManager.shared.search()
//        SBCentralManager.shared.beginRefreshRSSI()
        SBCentralManager.shared.observable.addObserver(.weak(self), { [unowned self] event in
            if case .findNewPeripheral(_) = event {
                self.peripherals = SBCentralManager.shared.peripheralList.peripherals
                self.listView.reloadData()
            } else if case .reconnect(let connectedPeripherals) = event {
                self.handleReconnectedPeripherals(connectedPeripherals)
            }
        })
        
        SBLogger.shared.logCallback = { log in
            switch log {
            case .success(let msg), .error(let msg), .info(let msg):
                print(msg ?? "")
            }
        }
    }
    
    private func handleReconnectedPeripherals(_ connectedPeripherals: [SBPeripheral]) {
        if connectedPeripherals.count < 1 { return }
        connectedPeripherals[1...].forEach { $0.disconnect() }
        Router.push(.peripheralInfo(connectedPeripherals[0]))
    }
    
    private func setupUI() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}

extension SearchViewController: QMUITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PeripheralSearchCell.self)) as! PeripheralSearchCell
        cell.peripheral = peripherals[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension SearchViewController: QMUITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
