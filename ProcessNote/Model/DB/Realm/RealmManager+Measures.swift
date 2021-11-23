//
//  RealmManager+Measures.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

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


// MARK: - Select

/**
 Realmの対策データを全取得
 - Returns: 全対策データ
 */
func selectAllMeasuresRealm() -> [Measures] {
    var realmMeasuresArray: [Measures] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Measures.self)
    for task in realmArray {
        realmMeasuresArray.append(task)
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
