//
//  RealmManager+Task.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import RealmSwift


// MARK: - Update

/**
 課題を更新(同期用)
 - Parameters:
    - task: 更新したい課題
 */
func updateTaskRealm(task: Task) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
    try! realm.write {
        result?.setGroupID(task.getGroupID())
        result?.setTitle(task.getTitle())
        result?.setCause(task.getCause())
        result?.setOrder(task.getOrder())
        result?.setUpdated_at(task.getUpdated_at())
        result?.setCompleted_at(task.getCompleted_at())
        result?.setIsCompleted(task.getIsCompleted())
        result?.setIsDeleted(task.getIsDeleted())
    }
}

/**
 課題のタイトルを更新
 - Parameters:
    - ID: 更新したい課題のID
    - title: 新しいタイトル文字列
 */
func updateTaskTitleRealm(ID taskID: String, title: String) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(taskID)'").first
    try! realm.write {
        result?.setTitle(title)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題の原因を更新
 - Parameters:
    - ID: 更新したい課題のID
    - cause: 新しい原因の文字列
 */
func updateTaskCauseRealm(ID taskID: String, cause: String) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(taskID)'").first
    try! realm.write {
        result?.setCause(cause)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題の並び順を更新
 - Parameters:
 - taskArray: 課題配列
 */
func updateTaskOrderRealm(taskArray: [[Task]]) {
    let realm = try! Realm()
    
    var index = 0
    for tasks in taskArray {
        for task in tasks {
            let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
            try! realm.write {
                result?.setOrder(index)
                result?.setUpdated_at(getCurrentTime())
            }
            index += 1
            if index > tasks.count - 1 {
                index = 0
                continue
            }
        }
    }
}

/**
 課題の並び順を更新
 - Parameters:
    - task: 課題
    - order: 並び順
 */
func updateTaskOrderRealm(task: Task, order: Int) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
    try! realm.write {
        result?.setOrder(order)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題の属するグループを更新
 - Parameters:
    - task: 課題
    - groupId: 更新後のgroupId
 */
func updateTaskGroupIdRealm(task: Task, ID: String) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
    try! realm.write {
        result?.setGroupID(ID)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題の完了フラグを更新
 - Parameters:
    - task: 課題
    - isCompleted: 完了or未完了
 */
func updateTaskIsCompleted(task: Task, isCompleted: Bool) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
    try! realm.write {
        result?.setIsCompleted(isCompleted)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題の削除フラグを更新
 - Parameters:
    - task: 課題
 */
func updateTaskIsDeleted(task: Task) {
    let realm = try! Realm()
    let result = realm.objects(Task.self).filter("taskID == '\(task.getTaskID())'").first
    try! realm.write {
        result?.setIsDeleted(true)
        result?.setUpdated_at(getCurrentTime())
    }
}

/**
 課題のユーザーIDを更新
 - Parameters:
    - userID: ユーザーID
 */
func updateTaskUserID(userID: String) {
    let realm = try! Realm()
    let result = realm.objects(Task.self)
    for task in result {
        try! realm.write {
            task.setUserID(userID)
        }
    }
}


// MARK: - Select

/**
 Realmの課題データを全取得
 - Returns: 全課題データ
 */
func getAllTaskRealm() -> [Task] {
    var realmTaskArray: [Task] = []
    let realm = try! Realm()
    let realmArray = realm.objects(Task.self)
    for task in realmArray {
        realmTaskArray.append(task)
    }
    return realmTaskArray
}

/**
 Realmの課題データを取得(ID指定)
 - Parameters:
    - ID: 取得したい課題のID
 - Returns: 課題データ
 */
func getTask(taskID: String) -> Task {
    let realm = try! Realm()
    return realm.objects(Task.self).filter("taskID == '\(taskID)'").first!
}

/**
 グループに含まれる課題を取得
 - Parameters:
    - groupID: グループID
    - isCompleted: 完了or未完了
 - Returns: グループに含まれる課題
 */
func getTasksInGroup(ID groupID: String, isCompleted: Bool) -> [Task] {
    var taskArray: [Task] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "order", ascending: true),
    ]
    let results = realm.objects(Task.self)
                        .filter("(groupID == '\(groupID)') && (isDeleted == false) && (isCompleted == \(String(isCompleted)))")
                        .sorted(by: sortProperties)
    for task in results {
        taskArray.append(task)
    }
    return taskArray
}

/**
 グループに含まれる課題を取得
 - Parameters:
    - groupID: グループID
 - Returns: グループに含まれる課題
 */
func getTasksInGroup(ID groupID: String) -> [Task] {
    var taskArray: [Task] = []
    let realm = try! Realm()
    let sortProperties = [
        SortDescriptor(keyPath: "order", ascending: true),
    ]
    let results = realm.objects(Task.self)
                        .filter("(groupID == '\(groupID)') && (isDeleted == false)")
                        .sorted(by: sortProperties)
    for task in results {
        taskArray.append(task)
    }
    return taskArray
}

/**
 TaskViewController用task配列を返却
 - Returns: Task配列[[task][task, task]…]の形
 */
func getTaskArrayForTaskView() -> [[Task]] {
    var taskArray: [[Task]] = [[Task]]()
    
    let groupArray: [Group] = getGroupArrayForTaskView()
    for group in groupArray {
        let tasks = getTasksInGroup(ID: group.getGroupID(), isCompleted: false)
        taskArray.append(tasks)
    }
    
    return taskArray
}

// MARK: - Delete

/// Realmのデータを全削除
func deleteAllTaskRealm() {
    let realm = try! Realm()
    let tasks = realm.objects(Task.self)
    do{
      try realm.write{
        realm.delete(tasks)
      }
    }catch {
      print("Error \(error)")
    }
}

