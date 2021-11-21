//
//  FirebaseManager+Task.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import Firebase


// MARK: - Variable

var firebaseTaskArray: [Task] = []


// MARK: - Create

/**
 課題データを保存
 - Parameters:
    - task: 保存する課題データ
    - completion: 完了処理
 */
func saveTask(task: Task, completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    db.collection("Task").document("\(task.getUserID())_\(task.getTaskID())").setData([
        "userID"        : task.getUserID(),
        "taskID"        : task.getTaskID(),
        "groupID"       : task.getGroupID(),
        "created_at"    : task.getCreated_at(),
        "title"         : task.getTitle(),
        "cause"         : task.getCause(),
        "order"         : task.getOrder(),
        "updated_at"    : task.getUpdated_at(),
        "completed_at"  : task.getCompleted_at(),
        "isCompleted"   : task.getIsCompleted(),
        "isDeleted"     : task.getIsDeleted()
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
 課題を更新
 - Parameters:
    - task: 課題データ
 */
func updateTask(_ task: Task) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    let database = db.collection("Task").document("\(userID)_\(task.getTaskID())")
    database.updateData([
        "groupID"       : task.getGroupID(),
        "title"         : task.getTitle(),
        "cause"         : task.getCause(),
        "order"         : task.getOrder(),
        "updated_at"    : task.getUpdated_at(),
        "completed_at"  : task.getCompleted_at(),
        "isCompleted"   : task.getIsCompleted(),
        "isDeleted"     : task.getIsDeleted()
    ]) { err in
        if let err = err {
            print("Error updating document: \(err)")
        } else {
        }
    }
}


// MARK: - Select

/**
 課題データを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllTask(completion: @escaping () -> ()) {
    let db = Firestore.firestore()
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    db.collection("Task")
        .whereField("userID", isEqualTo: userID)
        .getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            firebaseTaskArray = []
            for document in querySnapshot!.documents {
                let collection = document.data()
                let task = Task()
                task.setUserID(collection["userID"] as! String)
                task.setTaskID(collection["taskID"] as! String)
                task.setCreated_at(collection["created_at"] as! String)
                task.setGroupID(collection["groupID"] as! String)
                task.setTitle(collection["title"] as! String)
                task.setCause(collection["cause"] as! String)
                task.setOrder(collection["order"] as! Int)
                task.setUpdated_at(collection["updated_at"] as! String)
                task.setCompleted_at(collection["completed_at"] as! String)
                task.setIsCompleted(collection["isCompleted"] as! Bool)
                task.setIsDeleted(collection["isDeleted"] as! Bool)
                firebaseTaskArray.append(task)
            }
            completion()
        }
    }
}
