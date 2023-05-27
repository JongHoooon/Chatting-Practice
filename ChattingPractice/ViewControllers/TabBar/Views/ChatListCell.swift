//
//  ChatListCell.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import UIKit

final class ChatListCell: UITableViewCell {

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50.0 / 2
        imageView.clipsToBounds = true

        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()

        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()

        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        [
            profileImageView,
            titleLabel,
            lastMessageLabel
        ].forEach { contentView.addSubview($0) }

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8.0)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(50.0)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8.0)
        }

        lastMessageLabel.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8.0)
        }
    }
}
