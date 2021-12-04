//
//  RealmManager+Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import RealmSwift


// MARK: - Update

/**
 更新日時を更新
 - Parameters:
    - ID: 更新したいメモのID
 */
func updateMemoUpdatedAtRealm(ID memoID: String) {
    let realm = try! Realm()
    let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
    try! realm.write {
        result?.setUpdated_at(getCurrentTime())
    }
}

// MARK: - Select

/**
 Realmのメモデータを全取得
 - Returns: 全メモデータ
 */
func selectAllMemoRealm() -> [Memo] {
    var realmMemoArray: [Memo] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Memo.self)
    for memo in realmArray {
        realmMemoArray.append(memo)
    }
    return realmMemoArray
}
