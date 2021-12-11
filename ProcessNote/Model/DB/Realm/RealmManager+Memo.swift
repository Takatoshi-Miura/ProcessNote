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

/**
 メモの内容を更新
 - Parameters:
    - memo: メモ
 */
func updateMemoDetail(ID memoID: String, detail: String) {
    let realm = try! Realm()
    let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
    try! realm.write {
        result?.setDetail(detail)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 メモの削除フラグを更新
 - Parameters:
    - memo: メモ
 */
func updateMemoIsDeleted(memo: Memo) {
    let realm = try! Realm()
    let result = realm.objects(Memo.self).filter("memoID == '\(memo.getMemoID())'").first
    try! realm.write {
        result?.setIsDeleted(true)
        result?.setUpdated_at(getCurrentTime())
    }
}


// MARK: - Select

/**
 Realmのメモデータを全取得
 - Returns: 全メモデータ
 */
func getAllMemoRealm() -> [Memo] {
    var realmMemoArray: [Memo] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Memo.self)
    for memo in realmArray {
        realmMemoArray.append(memo)
    }
    return realmMemoArray
}

/**
 対策に含まれるメモを取得
 - Parameters:
    - measuresID: 対策ID
 - Returns: 対策に含まれるメモ
 */
func getMemo(measuresID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "created_at", ascending: false),
    ]
    let results = realm.objects(Memo.self)
                        .filter("(measuresID == '\(measuresID)') && (isDeleted == false)")
                        .sorted(by: sortProperties)
    for memo in results {
        memoArray.append(memo)
    }
    return memoArray
}

/**
 ノートに含まれるメモを取得
 - Parameters:
    - noteID: ノートID
 - Returns: ノートに含まれるメモ
 */
func getMemo(noteID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "created_at", ascending: false),
    ]
    let results = realm.objects(Memo.self)
                        .filter("(noteID == '\(noteID)') && (isDeleted == false)")
                        .sorted(by: sortProperties)
    for memo in results {
        memoArray.append(memo)
    }
    return memoArray
}

/**
 グループに含まれるメモを取得
 - Parameters:
    - noteID: ノートID
    - groupArray: グループ配列
 - Returns: メモ配列[[Memo]]
 */
func getMemo(noteID: String, groupArray: [Group]) -> [[Memo]] {
    var memoArray: [[Memo]] = []
    
    let memoInNote = getMemo(noteID: noteID)
    for group in groupArray {
        var array: [Memo] = []
        for memo in memoInNote {
            let groupID = getGroup(memo: memo).getGroupID()
            if groupID == group.getGroupID() {
                array.append(memo)
            }
        }
        memoArray.append(array)
    }
    
    return memoArray
}
