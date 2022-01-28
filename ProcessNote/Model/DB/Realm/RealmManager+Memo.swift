//
//  RealmManager+Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import RealmSwift


// MARK: - Update

/**
 メモを更新(同期用)
 - Parameters:
    - memo: 更新したいメモ
 */
func updateMemoRealm(memo: Memo) {
    let realm = try! Realm()
    let result = realm.objects(Memo.self).filter("memoID == '\(memo.getMemoID())'").first
    try! realm.write {
        result?.setDetail(memo.getDetail())
        result?.setUpdated_at(memo.getUpdated_at())
        result?.setIsDeleted(memo.getIsDeleted())
    }
}

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

/**
 ユーザーIDを更新
 - Parameters:
    - userID: ユーザーID
 */
func updateMemoUserID(userID: String) {
    let realm = try! Realm()
    let result = realm.objects(Memo.self)
    for memo in result {
        try! realm.write {
            memo.setUserID(userID)
        }
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
 Realmのメモデータを全取得(NoteViewController用)
 - Returns: 全メモデータ
 */
func getMemoArrayForNoteView() -> [Memo] {
    var realmMemoArray: [Memo] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "created_at", ascending: false),
    ]
    let realmArray = realm.objects(Memo.self)
                            .filter("(isDeleted == false)")
                            .sorted(by: sortProperties)
    for memo in realmArray {
        realmMemoArray.append(memo)
    }
    return realmMemoArray
}

/**
 グループに含まれるメモを取得
 - Returns: 検索フィルタの条件に合致するメモ
 */
func getMemoArrayWithGroupID(ID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realmMemoArray = getMemoArrayForNoteView()
    for memo in realmMemoArray {
        let memoGroupID = getGroup(memo: memo).getGroupID()
        if memoGroupID == ID {
            memoArray.append(memo)
        }
    }
    return memoArray
}

/**
 課題に含まれるメモを取得
 - Returns: 条件に合致するメモ
 */
func getMemoArrayWithTaskID(ID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realmMemoArray = getMemoArrayForNoteView()
    let measuresArray = getMeasuresInTask(ID: ID)
    for memo in realmMemoArray {
        for measures in measuresArray {
            if memo.getMeasuresID() == measures.getMeasuresID() {
                memoArray.append(memo)
            }
        }
    }
    return memoArray
}

/**
 Realmのメモデータを検索
 - Parameters:
    - searchWord: 検索文字列
 - Returns: 検索文字列を含むメモデータ
 */
func searchMemo(searchWord: String) -> [Memo] {
    var realmMemoArray: [Memo] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "created_at", ascending: false),
    ]
    let realmArray = realm.objects(Memo.self)
                            .filter("(isDeleted == false)")
                            .filter("(detail CONTAINS %@)", searchWord)
                            .sorted(by: sortProperties)
    for memo in realmArray {
        realmMemoArray.append(memo)
    }
    return realmMemoArray
}

/**
 Realmのメモデータを検索(課題フィルタ付き)
 - Parameters:
    - searchWord: 検索文字列
    - ID: 課題ID
 - Returns: 検索文字列を含むメモデータ
 */
func searchMemoWithTaskFilter(searchWord: String, ID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realmMemoArray = searchMemo(searchWord: searchWord)
    let measuresArray = getMeasuresInTask(ID: ID)
    for memo in realmMemoArray {
        for measures in measuresArray {
            if memo.getMeasuresID() == measures.getMeasuresID() {
                memoArray.append(memo)
            }
        }
    }
    return memoArray
}

/**
 Realmのメモデータを検索(グループフィルタ付き)
 - Parameters:
    - searchWord: 検索文字列
    - ID: グループID
 - Returns: 検索文字列を含むメモデータ
 */
func searchMemoWithGroupFilter(searchWord: String, ID: String) -> [Memo] {
    var memoArray: [Memo] = []
    let realmMemoArray = searchMemo(searchWord: searchWord)
    for memo in realmMemoArray {
        let memoGroupID = getGroup(memo: memo).getGroupID()
        if memoGroupID == ID {
            memoArray.append(memo)
        }
    }
    return memoArray
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


// MARK: - Delete

/// Realmのデータを全削除
func deleteAllMemoRealm() {
    let realm = try! Realm()
    let memos = realm.objects(Memo.self)
    do{
      try realm.write{
        realm.delete(memos)
      }
    }catch {
      print("Error \(error)")
    }
}
