//
//  RealmManager+Group.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

/**
 グループを更新(同期用)
 - Parameters:
    - group: 更新したいグループ
 */
func updateGroupRealm(group: Group) {
    let realm = try! Realm()
    let result = realm.objects(Group.self).filter("groupID == '\(group.getGroupID())'").first
    try! realm.write {
        result?.setColor(group.getColor())
        result?.setTitle(group.getTitle())
        result?.setOrder(group.getOrder())
        result?.setUpdated_at(group.getUpdated_at())
        result?.setCompleted_at(group.getCompleted_at())
        result?.setIsCompleted(group.getIsCompleted())
        result?.setIsDeleted(group.getIsDeleted())
    }
}

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

/**
 ユーザーIDを更新
 - Parameters:
    - userID: ユーザーID
 */
func updateGroupUserID(userID: String) {
    let realm = try! Realm()
    let result = realm.objects(Group.self)
    for group in result {
        try! realm.write {
            group.setUserID(userID)
        }
    }
}


// MARK: - Select

/**
 Realmのグループデータを全取得
 - Returns: 全グループデータ
 */
func getAllGroupRealm() -> [Group] {
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
func getGroup(ID groupID: String) -> Group {
    let realm = try! Realm()
    return realm.objects(Group.self).filter("groupID == '\(groupID)'").first!
}

/**
 メモが所属するグループを取得
 - Parameters:
    - memo: メモ
 - Returns: グループ
 */
func getGroup(memo: Memo) -> Group {
    let measures = getMeasures(measuresID: memo.getMeasuresID())
    let task = getTask(taskID: measures.getTaskID())
    return getGroup(ID: task.getGroupID())
}

/**
 TaskViewController用Group配列を取得
 - Returns: Group配列
 */
func getGroupArrayForTaskView() -> [Group] {
    var realmGroupArray: [Group] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "order", ascending: true),
    ]
    let results = realm.objects(Group.self)
                        .filter("(isDeleted == false)")
                        .sorted(by: sortProperties)
    for group in results {
        realmGroupArray.append(group)
    }
    return realmGroupArray
}

/**
 NoteDetailViewController用Group配列を取得
 - Parameters:
    - noteID: ノートID
 - Returns: Group配列
 */
func getGroupArrayForNoteDetailView(noteID: String) -> [Group] {
    // ノートに所属するメモを取得
    let memoArray = getMemo(noteID: noteID)
    
    // メモが所属するグループを重複なく取得
    var groupArray: [Group] = []
    for memo in memoArray {
        let group = getGroup(memo: memo)
        groupArray.append(group)
    }
    var groups: [Group] = []
    for group in Set(groupArray) {
        groups.append(group)
    }
    return groups
}


// MARK: - Delete

/// Realmのデータを全削除
func deleteAllGroupRealm() {
    let realm = try! Realm()
    let groups = realm.objects(Group.self)
    do{
      try realm.write{
        realm.delete(groups)
      }
    }catch {
      print("Error \(error)")
    }
}
