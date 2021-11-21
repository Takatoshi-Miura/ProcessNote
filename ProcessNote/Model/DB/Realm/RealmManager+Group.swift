//
//  RealmManager+Group.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

/**
 グループの削除フラグを更新
 - Parameters:
    - group: グループ
 */
func updateGroupIsDeleted(group: Group) {
    let realm = try! Realm()
    let result = realm.objects(Group.self).filter("groupID == '\(group.getGroupID())'").first
    try! realm.write {
        result?.setIsDeleted(true)
        result?.setUpdated_at(getCurrentTime())
    }
}


// MARK: - Select

/**
 Realmのグループデータを全取得
 - Returns: 全グループデータ
 */
func selectAllGroupRealm() -> [Group] {
    var realmGroupArray: [Group] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Group.self)
    for group in realmArray {
        realmGroupArray.append(group)
    }
    return realmGroupArray
}
