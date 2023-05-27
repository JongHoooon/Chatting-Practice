//
//  PeopleTableViewCell.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import UIKit

final class PeopleTableViewCell: UITableViewCell {
    
    var profileImageView: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [
            profileImageView,
            label
        ].forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
