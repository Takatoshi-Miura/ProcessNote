//
//  FirebaseManager+Note.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import Firebase


// MARK: - Variable

var firebaseNoteArray: [Note] = []


// MARK: - Create

/**
 ノートデータを保存
 - Parameters:
    - note: 保存するノートデータ
    - completion: 完了処理
 */
func saveNote(note: Note, completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    db.collection("Note").document("\(note.getUserID())_\(note.getNoteID())").setData([
        "userID"        : note.getUserID(),
        "noteID"        : note.getNoteID(),
        "created_at"    : note.getCreated_at(),
        "updated_at"    : note.getUpdated_at(),
        "isDeleted"     : note.getIsDeleted()
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
 ノートを更新
 - Parameters:
    - note: ノートデータ
 */
func updateNote(_ note: Note) {
    let db = Firestore.firestore()
    let database = db.collection("Note").document("\(note.getUserID())_\(note.getNoteID())")
    database.updateData([
        "updated_at"    : note.getUpdated_at(),
        "isDeleted"     : note.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
        } else {
        }
    }
}


// MARK: - Select

/**
 ノートデータを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllNote(completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    db.collection("Note")
        .whereField("userID", isEqualTo: userID)
        .getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            firebaseNoteArray = []
            for document in querySnapshot!.documents {
                let collection = document.data()
                let note = Note()
                note.setUserID(collection["userID"] as! String)
                note.setNoteID(collection["noteID"] as! String)
                note.setCreated_at(collection["created_at"] as! String)
                note.setUpdated_at(collection["updated_at"] as! String)
                note.setIsDeleted(collection["isDeleted"] as! Bool)
                firebaseNoteArray.append(note)
            }
            completion()
        }
    }
}
