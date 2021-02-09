//
//  WriteCell.swift
//  Bluetooth-Controller
//
//  Created by Rebecca on 2021/2/8.
//

import UIKit
import QMUIKit
import RxCocoa
import RxSwift
import SimpleBluetooth

class WriteCell: UITableViewCell {
    
    private let bag = DisposeBag()
    
    public var characteristic: SBCharacteristic?
    
    private lazy var textFiled = config(UITextField()) {
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.keyboardType = .asciiCapable
        $0.placeholder = "Send value ..."
        $0.returnKeyType = .send
        $0.clearButtonMode = .always
        $0.delegate = self
    }
    
    private lazy var sendBtn = config(QMUIFillButton(fill: UIColor.pg.btnBgBlue,
                                                     titleTextColor: UIColor.pg.btnTitle))
    {
        $0.setTitle("Send", for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(textFiled)
        contentView.addSubview(sendBtn)

        textFiled.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.centerY.equalTo(contentView)
            $0.trailing.equalTo(-100)
            $0.height.equalTo(36)
        }
        
        sendBtn.snp.makeConstraints {
            $0.leading.equalTo(textFiled.snp.trailing).offset(10)
            $0.height.centerY.equalTo(textFiled)
            $0.trailing.equalTo(-10)
        }
        
        sendBtn.rx.tap.subscribe(onNext: { [unowned self] in
            self.sendData()
        }).disposed(by: bag)
        
    }
    
    private func sendData() {
        guard let data = textFiled.text?.data(using: .utf8),
              let characteristic = characteristic,
              characteristic.canWrite
              else { return }
        characteristic.write(data)
    }
}

extension WriteCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendData()
        return true
    }
}
