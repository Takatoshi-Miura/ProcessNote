//
//  FirebaseManager.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import Firebase

// MARK: - Variable

var firebaseGroupArray: [Group] = []
var firebaseTaskArray: [Task] = []
var firebaseMeasuresArray: [Measures] = []


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
 課題を更新
 - Parameters:
    - task: 課題データ
 */
func updateTask(_ task: Task) {
    // ユーザーIDを取得
    let userID = UserDefaults.standard.object(forKey: "userID") as! String
    
    // 更新処理
    let db = Firestore.firestore()
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
 グループデータを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllGroup(completion: @escaping () -> ()) {
    // ユーザーIDを取得
    let userID = UserDefaults.standard.object(forKey: "userID") as! String

    // 現在のユーザーのデータを取得する
    let db = Firestore.firestore()
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

/**
 課題データを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllTask(completion: @escaping () -> ()) {
    // ユーザーIDを取得
    let userID = UserDefaults.standard.object(forKey: "userID") as! String

    // 現在のユーザーのデータを取得する
    let db = Firestore.firestore()
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

/**
 対策データを全取得
 - Parameters:
    - completion: 完了処理
 */
func getAllMeasures(completion: @escaping () -> ()) {
    // ユーザーIDを取得
    let userID = UserDefaults.standard.object(forKey: "userID") as! String

    // 現在のユーザーのデータを取得する
    let db = Firestore.firestore()
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

// MARK: - Delete

