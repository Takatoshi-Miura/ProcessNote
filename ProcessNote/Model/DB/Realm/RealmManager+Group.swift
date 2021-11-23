//
//  RealmManager+Group.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

/**
 グループのタイトルを更新
 - Parameters:
    - ID: 更新したいグループのID
    - title: 新しいタイトル文字列
 */
func updateGroupTitleRealm(ID groupID: String, title: String) {
    let realm = try! Realm()
    let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
    try! realm.write {
        result?.setTitle(title)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 グループの色を更新
 - Parameters:
    - ID: 更新したいグループのID
    - colorNumber: 新しい色番号
 */
func updateGroupColorRealm(ID groupID: String, colorNumber: Int) {
    let realm = try! Realm()
    let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
    try! realm.write {
        result?.setColor(colorNumber)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 グループの並び順を更新
 - Parameters:
    - groupArray: グループ配列
 */
func updateGroupOrderRealm(groupArray: [Group]) {
    let realm = try! Realm()
    var index = 0
    for group in groupArray {
        let result = realm.objects(Group.self).filter("groupID == '\(group.getGroupID())'").first
        try! realm.write {
            result?.setOrder(index)
            result?.setUpdated_at(getCurrentTime())
        }
        index += 1
    }
}

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

/**
 Realmのグループデータを取得(ID指定)
 - Parameters:
    - ID: 取得したいグループのID
 - Returns: グループデータ
 */
func selectGroupRealm(ID groupID: String) -> Group {
    let realm = try! Realm()
    return realm.objects(Group.self).filter("groupID == '\(groupID)'").first!
}
