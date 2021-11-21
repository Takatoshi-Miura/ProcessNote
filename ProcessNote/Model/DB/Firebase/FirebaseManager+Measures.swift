//
//  FirebaseManager+Measures.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import Firebase


// MARK: - Variable

var firebaseMeasuresArray: [Measures] = []


// MARK: - Create

/**
 対策データを保存
 - Parameters:
    - measures: 保存する対策データ
    - completion: 完了処理
 */
func saveMeasures(measures: Measures, completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    db.collection("Measures").document("\(measures.getUserID())_\(measures.getMeasuresID())").setData([
        "userID"        : measures.getUserID(),
        "measuresID"    : measures.getMeasuresID(),
        "taskID"        : measures.getTaskID(),
        "created_at"    : measures.getCreated_at(),
        "title"         : measures.getTitle(),
        "order"         : measures.getOrder(),
        "updated_at"    : measures.getUpdated_at(),
        "isDeleted"     : measures.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            completion()
        }
    }
}


// MARK: - Update

/**
 対策を更新
 - Parameters:
    - measures: 対策データ
 */
func updateMeasures(_ measures: Measures) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    let database = db.collection("Measures").document("\(userID)_\(measures.getMeasuresID())")
    database.updateData([
        "title"         : measures.getTitle(),
        "order"         : measures.getOrder(),
        "updated_at"    : measures.getUpdated_at(),
        "isDeleted"     : measures.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
        } else {
        }
    }
}


// MARK: - Select

/**
 対策データを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllMeasures(completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    db.collection("Measures")
        .whereField("userID", isEqualTo: userID)
        .getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            firebaseMeasuresArray = []
            for document in querySnapshot!.documents {
                let collection = document.data()
                let measures = Measures()
                measures.setUserID(collection["userID"] as! String)
                measures.setMeasuresID(collection["measuresID"] as! String)
                measures.setTaskID(collection["taskID"] as! String)
                measures.setCreated_at(collection["created_at"] as! String)
                measures.setTitle(collection["title"] as! String)
                measures.setOrder(collection["order"] as! Int)
                measures.setUpdated_at(collection["updated_at"] as! String)
                measures.setIsDeleted(collection["isDeleted"] as! Bool)
                firebaseMeasuresArray.append(measures)
            }
            completion()
        }
    }
}
