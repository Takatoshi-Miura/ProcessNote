//
//  RealmManager+Note.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import RealmSwift


// MARK: - Update

/**
 更新日時を更新
 - Parameters:
    - ID: 更新したいノートのID
 */
func updateNoteUpdatedAtRealm(ID noteID: String) {
    let realm = try! Realm()
    let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
    try! realm.write {
        result?.setUpdated_at(getCurrentTime())
    }
}

// MARK: - Select

/**
 Realmのノートデータを全取得
 - Returns: 全ノートデータ
 */
func selectAllNoteRealm() -> [Note] {
    var realmNoteArray: [Note] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Note.self)
    for note in realmArray {
        realmNoteArray.append(note)
    }
    return realmNoteArray
}

/**
 NoteViewController用note配列を返却
 - Returns: Note配列
 */
func getNoteArrayForNoteView() -> [Note] {
    var realmNoteArray: [Note] = []
    
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "created_at", ascending: true),
    ]
    let results = realm.objects(Note.self)
                        .filter("(isDeleted == false)")
                        .sorted(by: sortProperties)
    for note in results {
        realmNoteArray.append(note)
    }
    
    return realmNoteArray
}

/**
 今日の日付のノートを取得
 - Returns: ノート(存在しなければnil)
 */
func selectTodayNote() -> Note? {
    let realm = try! Realm()
    let today = getCurrentDate()
    let results = realm.objects(Note.self)
                        .filter("(created_at == '\(today)') && (isDeleted == false)")
    return results.first
}
