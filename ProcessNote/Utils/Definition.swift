//
//  Definition.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import Foundation
import UIKit

// ColorPicker用(どこに追加してもOK)
let colorTitle: [String] = [NSLocalizedString("Red", comment: ""),
                            NSLocalizedString("Pink", comment: ""),
                            NSLocalizedString("Orange", comment: ""),
                            NSLocalizedString("Yellow", comment: ""),
                            NSLocalizedString("Green", comment: ""),
                            NSLocalizedString("Blue", comment: ""),
                            NSLocalizedString("Purple", comment: ""),
                            NSLocalizedString("White", comment: ""),
                            NSLocalizedString("Black", comment: "")]

// DB保存用(追加するときはDBとの整合を保つため最後尾に追加する)
let colorNumber: [String : Int] = [NSLocalizedString("Red", comment: "") : 0,
                                   NSLocalizedString("Pink", comment: "") : 1,
                                   NSLocalizedString("Orange", comment: "") : 2,
                                   NSLocalizedString("Yellow", comment: "") : 3,
                                   NSLocalizedString("Green", comment: "") : 4,
                                   NSLocalizedString("Blue", comment: "") : 5,
                                   NSLocalizedString("Purple", comment: "") : 6,
                                   NSLocalizedString("White", comment: "") : 7,
                                   NSLocalizedString("Black", comment: "") : 8]

let color: [Int : UIColor] = [0 : UIColor.systemRed,
                              1 : UIColor.systemPink,
                              2 : UIColor.systemOrange,
                              3 : UIColor.systemYellow,
                              4 : UIColor.systemGreen,
                              5 : UIColor.systemBlue,
                              6 : UIColor.systemPurple,
                              7 : UIColor.white,
                              8 : UIColor.black]

/**
 現在時刻を取得
 - Returns: 現在時刻（yyyy-MM-dd HH:mm:ss）
 */
func getCurrentTime() -> String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: now)
}

/**
 現在の日付を取得
 - Returns: 日付（yyyy-MM-dd）
 */
func getCurrentDate() -> String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: now)
}

/**
 日付をyyyy/MM/ddに変換
 - Parameters:
    - dateString: 日付文字列
    - format: フォーマット("yyyy-MM-dd HH:mm:ss"等)
 - Returns: 日付（yyyy/MM/dd）
 */
func changeDateString(dateString: String, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.dateFormat = format
    let date = dateFormatter.date(from: dateString)!
    dateFormatter.dateFormat = "yyyy/MM/dd"
    return dateFormatter.string(from: date)
}

/**
 String型からDate型に変換
 - Parameters:
    - string: 変換したい文字列
 - Returns: Date型
 */
func dateFromString(_ string: String) -> Date {
    let formatter: DateFormatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.date(from: string)!
}

extension Array where Element: Equatable {
    typealias E = Element

    func subtracting(_ other: [E]) -> [E] {
        return self.compactMap { element in
            if (other.filter { $0 == element }).count == 0 {
                return element
            } else {
                return nil
            }
        }
    }

    mutating func subtract(_ other: [E]) {
        self = subtracting(other)
    }
}
