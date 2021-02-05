//
//  InfoHeader.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/25.
//

import UIKit
import QMUIKit

class InfoHeader: UITableViewHeaderFooterView {
    var title: String? { didSet { titleLabel.text = title } }
    
    private lazy var titleLabel = config(QMUILabel()) {
        $0.font = .systemFont(ofSize: 17, weight: .thin)
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.bottom.equalTo(-5)
        }
    }
}
