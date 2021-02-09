//
//  InfoCell.swift
//  Bluetooth-Controller
//
//  Created by caishilin on 2021/1/25.
//

import UIKit
import QMUIKit

class InfoCell: UITableViewCell {
    
    var title: String? { didSet { titleLabel.text = title } }
    var subtitle: String? { didSet { subtitleLabel.text = subtitle } }
    
    private lazy var titleLabel = config(QMUILabel()) {
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = UIColor.pg.title
    }
    private lazy var subtitleLabel = config(QMUILabel()) {
        $0.font = .systemFont(ofSize: 13, weight: .ultraLight)
        $0.textColor = UIColor.pg.subtitle
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setupUI() {
        accessoryType = .disclosureIndicator
        backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.top.equalTo(5)
        }
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(20)
            $0.bottom.equalTo(-5)
        }
    }
}
