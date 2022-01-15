//
//  FirebaseManager+Group.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import Firebase


// MARK: - Variable

var firebaseGroupArray: [Group] = []


// MARK: - Create

/**
 グループデータを保存
 - Parameters:
    - group: 保存するグループデータ
    - completion: 完了処理
 */
func saveGroup(group: Group, completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    db.collection("Group").document("\(group.getUserID())_\(group.getGroupID())").setData([
        "userID"        : group.getUserID(),
        "groupID"       : group.getGroupID(),
        "created_at"    : group.getCreated_at(),
        "color"         : group.getColor(),
        "title"         : group.getTitle(),
        "order"         : group.getOrder(),
        "updated_at"    : group.getUpdated_at(),
        "completed_at"  : group.getCompleted_at(),
        "isCompleted"   : group.getIsCompleted(),
        "isDeleted"     : group.getIsDeleted()
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
 グループを更新
 - Parameters:
    - group: グループデータ
 */
func updateGroup(group: Group) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    let database = db.collection("Group").document("\(userID)_\(group.getGroupID())")
    database.updateData([
        "color"         : group.getColor(),
        "title"         : group.getTitle(),
        "order"         : group.getOrder(),
        "updated_at"    : group.getUpdated_at(),
        "completed_at"  : group.getCompleted_at(),
        "isCompleted"   : group.getIsCompleted(),
        "isDeleted"     : group.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
        } else {
        }
    }
}


// MARK: - Select

/**
 グループデータを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllGroup(completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    db.collection("Group")
        .whereField("userID", isEqualTo: userID)
        .getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            firebaseGroupArray = []
            for document in querySnapshot!.documents {
                let collection = document.data()
                let group = Group()
                group.setUserID(collection["userID"] as! String)
                group.setGroupID(collection["groupID"] as! String)
                group.setCreated_at(collection["created_at"] as! String)
                group.setColor(collection["color"] as! Int)
                group.setTitle(collection["title"] as! String)
                group.setOrder(collection["order"] as! Int)
                group.setUpdated_at(collection["updated_at"] as! String)
                group.setCompleted_at(collection["completed_at"] as! String)
                group.setIsCompleted(collection["isCompleted"] as! Bool)
                group.setIsDeleted(collection["isDeleted"] as! Bool)
                firebaseGroupArray.append(group)
            }
            completion()
        }
    }
}
