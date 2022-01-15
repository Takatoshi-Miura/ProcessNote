//
//  RealmManager+Measures.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

/**
 対策を更新(同期用)
 - Parameters:
    - measures: 更新したい対策
 */
func updateMeasuresRealm(measures: Measures) {
    let realm = try! Realm()
    let result = realm.objects(Measures.self).filter("measuresID == '\(measures.getMeasuresID())'").first
    try! realm.write {
        result?.setTitle(measures.getTitle())
        result?.setOrder(measures.getOrder())
        result?.setUpdated_at(measures.getUpdated_at())
        result?.setIsDeleted(measures.getIsDeleted())
    }
}

/**
 対策のタイトルを更新
 - Parameters:
    - ID: 更新したい対策のID
    - title: 新しいタイトル文字列
 */
func updateMeasuresTitleRealm(ID measuresID: String, title: String) {
    let realm = try! Realm()
    let result = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
    try! realm.write {
        result?.setTitle(title)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 対策の並び順を更新
 - Parameters:
 - measuresArray: 対策配列
 */
func updateMeasuresOrderRealm(measuresArray: [Measures]) {
    let realm = try! Realm()
    var index = 0
    for measures in measuresArray {
        let result = realm.objects(Measures.self).filter("measuresID == '\(measures.getMeasuresID())'").first
        try! realm.write {
            result?.setOrder(index)
            result?.setUpdated_at(getCurrentTime())
        }
        index += 1
    }
}

/**
 対策の削除フラグを更新
 - Parameters:
    - measures: 対策
 */
func updateMeasuresIsDeleted(measures: Measures) {
    let realm = try! Realm()
    let result = realm.objects(Measures.self).filter("measuresID == '\(measures.getMeasuresID())'").first
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
func updateMeasuresUserID(userID: String) {
    let realm = try! Realm()
    let result = realm.objects(Measures.self)
    for measures in result {
        try! realm.write {
            measures.setUserID(userID)
        }
    }
}


// MARK: - Select

/**
 Realmの対策データを全取得
 - Returns: 全対策データ
 */
func getAllMeasuresRealm() -> [Measures] {
    var realmMeasuresArray: [Measures] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Measures.self)
    for task in realmArray {
        realmMeasuresArray.append(task)
    }
    return realmMeasuresArray
}

/**
 Realmの対策データを全取得
 - Parameters:
    - isDeleted: 対策の削除状況
 - Returns: 全対策データ
 */
func getAllMeasures(isDeleted: Bool) -> [Measures] {
    var realmMeasuresArray: [Measures] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Measures.self)
                            .filter("isDeleted == \(isDeleted)")
    for measures in realmArray {
        realmMeasuresArray.append(measures)
    }
    return realmMeasuresArray
}

/**
 課題に含まれる対策を取得
 - Parameters:
    - taskID: 課題ID
 - Returns: 課題に含まれる対策
 */
func getMeasuresInTask(ID taskID: String) -> [Measures] {
    var measuresArray: [Measures] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "order", ascending: true),
    ]
    let results = realm.objects(Measures.self)
                        .filter("taskID == '\(taskID)' && (isDeleted == false)")
                        .sorted(by: sortProperties)
    for measures in results {
        measuresArray.append(measures)
    }
    return measuresArray
}

/**
 対策を取得
 - Parameters:
    - measuresID: 対策ID
 - Returns: 対策
 */
func getMeasures(measuresID: String) -> Measures {
    let realm = try! Realm()
    return realm.objects(Measures.self)
            .filter("measuresID == '\(measuresID)' && (isDeleted == false)")
            .first!
}

/**
 課題に含まれる最優先の対策名を取得
 - Parameters:
    - taskID: 課題ID
 - Returns: 対策名
 */
func getMeasuresTitleInTask(ID taskID: String) -> String {
    var measuresArray: [Measures] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "order", ascending: true),
    ]
    let results = realm.objects(Measures.self)
                        .filter("taskID == '\(taskID)' && (isDeleted == false)")
                        .sorted(by: sortProperties)
    for measures in results {
        measuresArray.append(measures)
    }
    return measuresArray.first?.getTitle() ?? ""
}


// MARK: - Delete

/// Realmのデータを全削除
func deleteAllMeasuresRealm() {
    let realm = try! Realm()
    let measures = realm.objects(Measures.self)
    do{
      try realm.write{
        realm.delete(measures)
      }
    }catch {
      print("Error \(error)")
    }
}
