//
//  Int+Extension.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import Foundation

extension Int {
    
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
}
