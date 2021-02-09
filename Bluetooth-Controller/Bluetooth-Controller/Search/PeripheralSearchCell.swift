//
//  PeripheralSearchCell.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/24.
//

import UIKit
import SimpleBluetooth
import QMUIKit
import SnapKit

class PeripheralSearchCell: QMUITableViewCell {
    var peripheral: SBPeripheral? {
        willSet {
            peripheral?.observable.removeObserver(.weak(self))
        }
        didSet {
            observePeripheral()
            updateUI()
        }
    }
    
    private lazy var titleLabel = config(QMUILabel()) {
        $0.textColor = UIColor.pg.title
        $0.font = .systemFont(ofSize: 18, weight: .light)
    }
    
    private lazy var signalStrengthIndicator = config(QMUIPieProgressView()) {
        $0.tintColor = .yellow
        $0.shape = .sector
    }
    
    private lazy var signalStrengthLabel = config(QMUILabel()) {
        $0.textColor = UIColor.pg.title
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private lazy var connectBtn = config(QMUIFillButton()) {
        $0.setTitle("Connect", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.tintColor = UIColor.pg.btnBgBlue
        $0.highlightedBackgroundColor = .cyan
        $0.setTitleColor(UIColor.pg.btnTitle, for: .normal)
        $0.addTarget(self, action: #selector(gotoConnect), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(signalStrengthIndicator)
        signalStrengthIndicator.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.top.equalTo(20)
            $0.bottom.equalTo(-40)
            $0.width.equalTo(signalStrengthIndicator.snp.height)
        }
        
        contentView.addSubview(signalStrengthLabel)
        signalStrengthLabel.snp.makeConstraints {
            $0.centerX.equalTo(signalStrengthIndicator)
            $0.bottom.equalTo(-13)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(signalStrengthIndicator.snp.trailing).offset(20)
            $0.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(connectBtn)
        connectBtn.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.trailing.equalTo(-20)
            $0.height.equalTo(30)
            $0.width.equalTo(80)
        }
    }
    
    private func updateUI() {
        titleLabel.text = peripheral?.name ?? "Unnamed"
        updateSignalStrength(peripheral?.RSSI ?? .init(value: 0))
    }
    
    private func updateSignalStrength(_ value: NSNumber) {
        let strength =  Float((value.intValue) + 100) / 100.0
        signalStrengthIndicator.progress = strength
        signalStrengthIndicator.tintColor = .qmui_color(from: .red, to: .green, progress: CGFloat(strength))
        signalStrengthLabel.text = "\(value.intValue)"
    }
    
    private func observePeripheral() {
        peripheral?.observable.addObserver(.weak(self), { [weak self] event in
            self?.handle(event: event)
        })
    }
    
    private func handle(event: SBPeripheral.Event) {
        switch event {
        case .didConnect:
            QMUITips.hideAllTips()
            QMUITips.showSucceed("Connect success")
            enterPeripheralInfoPage()
        case .didDisConnect:
            QMUITips.hideAllTips()
            QMUITips.showError("Disconnect")
        case .failToConnect:
            QMUITips.hideAllTips()
            QMUITips.showError("Fail to connect")
        case .read(RSSI: let rssi):
            updateSignalStrength(rssi)
        default:
            return
        }
    }
    
    @objc private func gotoConnect() {
        peripheral?.connect()
        QMUITips.showLoading("Connecting", in: UIApplication.shared.windows.first!)
    }
    
    private func enterPeripheralInfoPage() {
        guard let peripheral = peripheral, !(Router.topVC is PeripheralInfoViewController) else { return }
        Router.push(.peripheralInfo(peripheral))
    }
}
