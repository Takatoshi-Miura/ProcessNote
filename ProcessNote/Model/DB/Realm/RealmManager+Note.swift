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

/**
 ノートの削除フラグを更新
 - Parameters:
    - note: ノート
 */
func updateNoteIsDeleted(note: Note) {
    let realm = try! Realm()
    let result = realm.objects(Note.self).filter("noteID == '\(note.getNoteID())'").first
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
func updateNoteUserID(userID: String) {
    let realm = try! Realm()
    let result = realm.objects(Note.self)
    for note in result {
        try! realm.write {
            note.setUserID(userID)
        }
    }
}


// MARK: - Select

/**
 Realmのノートデータを全取得
 - Returns: 全ノートデータ
 */
func getAllNoteRealm() -> [Note] {
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
//func getNoteArrayForNoteView() -> [[Note]] {
//    var realmNoteArray: [Note] = []
//    
//    let realm = try! Realm()
//    let sortProperties = [
//        SortDescriptor(keyPath: "created_at", ascending: false),
//    ]
//    let results = realm.objects(Note.self)
//                        .filter("(isDeleted == false)")
//                        .sorted(by: sortProperties)
//    for note in results {
//        realmNoteArray.append(note)
//    }
//    
//    return sortNoteArrayByCreatedAt(noteArray: realmNoteArray)
//}

/**
 ノートを年月で配列に分ける(NoteViewController用)
 - Parameters:
    - noteArray: ノート配列
 - Returns: 年月別に分けられたノート配列
 */
//func sortNoteArrayByCreatedAt(noteArray: [Note]) -> [[Note]] {
//    // ノートの作成年月を重複なく抽出
//    let yearAndMonthSet = getNoteYearAndMonth()
//    
//    // 抽出した年月に合致するノートをまとめる
//    // 例：2021/12/3、2021/12/2、2021/11/23のノートがある場合 → [[2021/12/3, 2021/12/2], [2021/11/23]]と分ける)
//    var sortedNoteArray = [[Note]]()
//    for time in yearAndMonthSet {
//        var monthNoteArray: [Note] = []
//        for note in noteArray {
//            if getCreatedYearAndMonth(note: note) == time {
//                monthNoteArray.append(note)
//            }
//        }
//        sortedNoteArray.append(monthNoteArray)
//    }
//    return sortedNoteArray
//}

/**
 ノートの作成年月の種類を取得
 - Returns: ノートの年月(yyyy/MM形式)
 */
//func getNoteYearAndMonth() -> [String] {
//    // ノートを取得
//    var realmNoteArray: [Note] = []
//    let realm = try! Realm()
//    let sortProperties = [
//        SortDescriptor(keyPath: "created_at", ascending: false),
//    ]
//    let results = realm.objects(Note.self)
//                        .filter("(isDeleted == false)")
//                        .sorted(by: sortProperties)
//    for note in results {
//        realmNoteArray.append(note)
//    }
//
//    // ノートの作成年月を重複なく抽出
//    // 例：2021/12/3、2021/12/2、2021/11/23のノートがある場合 → 2021/12、2021/11のノートが存在する)
//    var yearAndMonthArray: [String] = []
//    for note in realmNoteArray {
//        yearAndMonthArray.append(getCreatedYearAndMonth(note: note))
//    }
//    var noteYearAndMonth: [String] = []
//    for time in Set(yearAndMonthArray) {
//        noteYearAndMonth.append(time)
//    }
//    noteYearAndMonth.sort { $0 > $1 }
//    return noteYearAndMonth
//}

/**
 ノートの年月を取得
 - Parameters:
    - note: ノート
 - Returns: ノートの年月(yyyy-MM形式)
 */
func getCreatedYearAndMonth(note: Note) -> String {
    return changeDateString(dateString: note.getCreated_at(), format: "yyyy-MM-dd", goalFormat: "yyyy / MM")
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


// MARK: - Delete

/// Realmのデータを全削除
func deleteAllNoteRealm() {
    let realm = try! Realm()
    let notes = realm.objects(Note.self)
    do{
      try realm.write{
        realm.delete(notes)
      }
    }catch {
      print("Error \(error)")
    }
}
