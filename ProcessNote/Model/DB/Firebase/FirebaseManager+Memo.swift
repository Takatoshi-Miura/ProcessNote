//
//  FirebaseManager+Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import Firebase


// MARK: - Variable

var firebaseMemoArray: [Memo] = []


// MARK: - Create

/**
 メモデータを保存
 - Parameters:
    - memo: 保存するメモデータ
    - completion: 完了処理
 */
func saveMemo(memo: Memo, completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    db.collection("Memo").document("\(memo.getUserID())_\(memo.getMemoID())").setData([
        "userID"        : memo.getUserID(),
        "memoID"        : memo.getMemoID(),
        "noteID"        : memo.getNoteID(),
        "measuresID"    : memo.getMeasuresID(),
        "created_at"    : memo.getCreated_at(),
        "detail"        : memo.getDetail(),
        "updated_at"    : memo.getUpdated_at(),
        "isDeleted"     : memo.getIsDeleted()
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
 メモを更新
 - Parameters:
    - memo: メモデータ
 */
func updateMemo(memo: Memo) {
    let db = Firestore.firestore()
    let database = db.collection("Memo").document("\(memo.getUserID())_\(memo.getMemoID())")
    database.updateData([
        "detail"        : memo.getDetail(),
        "updated_at"    : memo.getUpdated_at(),
        "isDeleted"     : memo.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
        } else {
        }
    }
}


// MARK: - Select

/**
 メモデータを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllMemo(completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    db.collection("Memo")
        .whereField("userID", isEqualTo: userID)
        .getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            firebaseMemoArray = []
            for document in querySnapshot!.documents {
                let collection = document.data()
                let memo = Memo()
                memo.setUserID(collection["userID"] as! String)
                memo.setMemoID(collection["memoID"] as! String)
                memo.setNoteID(collection["noteID"] as! String)
                memo.setMeasuresID(collection["measuresID"] as! String)
                memo.setCreated_at(collection["created_at"] as! String)
                memo.setDetail(collection["detail"] as! String)
                memo.setUpdated_at(collection["updated_at"] as! String)
                memo.setIsDeleted(collection["isDeleted"] as! Bool)
                firebaseMemoArray.append(memo)
            }
            completion()
        }
    }
}
