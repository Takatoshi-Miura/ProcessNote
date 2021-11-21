//
//  RealmManager.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import RealmSwift


// MARK: - Create

/**
 Realmにデータを作成
 - Parameters:
    - object: Realmオブジェクト
 - Returns: 成功失敗
 */
func createRealm(object: Object) -> Bool {
    do {
        let realm = try Realm()
        try realm.write {
            realm.add(object)
        }
    } catch {
        return false
    }
    return true
}
