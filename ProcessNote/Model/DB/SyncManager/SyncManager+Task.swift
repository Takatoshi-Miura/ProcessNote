//
//  SyncManager+Task.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//


/**
 課題を同期
 - Parameters:
    - completion: 完了処理
 */
func syncTask(completion: @escaping () -> ()) {
    // Realmの課題を全取得
    let realmTaskArray: [Task] = getAllTaskRealm()
    
    // Firebaseの課題を全取得
    getAllTask(completion: {
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseTaskIDArray = getTaskIDArray(array: firebaseTaskArray)
        let realmTaskIDArray = getTaskIDArray(array: realmTaskArray)
        let onlyRealmID = realmTaskIDArray.subtracting(firebaseTaskIDArray)
        let onlyFirebaseID = firebaseTaskIDArray.subtracting(realmTaskIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存
        for taskID in onlyRealmID {
            let task = getTaskWithID(array: realmTaskArray, ID: taskID)
            saveTask(task: task, completion: {})
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        for taskID in onlyFirebaseID {
            let task = getTaskWithID(array: firebaseTaskArray, ID: taskID)
            if !createRealm(object: task) {
                return
            }
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        let commonID = realmTaskIDArray.subtracting(onlyRealmID)
        for taskID in commonID {
            let realmTask = getTaskWithID(array: realmTaskArray, ID: taskID)
            let firebaseTask = getTaskWithID(array: firebaseTaskArray, ID: taskID)
            let realmDate = dateFromString(realmTask.getUpdated_at())
            let firebaseDate = dateFromString(firebaseTask.getUpdated_at())
            
            if realmDate > firebaseDate {
                // Realmデータの方が新しい
                saveTask(task: realmTask, completion: {})
            } else if firebaseDate > realmDate  {
                // Firebaseデータの方が新しい
                if !createRealm(object: firebaseTask) {
                    return
                }
            }
        }
        completion()
    })
}

/**
 Task配列からtaskID配列を作成
 - Parameters:
    - array: Task配列
 - Returns: taskID配列
 */
func getTaskIDArray(array: [Task]) -> [String] {
    var taskIDArray: [String] = []
    for task in array {
        taskIDArray.append(task.getTaskID())
    }
    return taskIDArray
}

/**
 Task配列からTaskを取得(taskID指定)
 - Parameters:
    - array: 検索対象のTask配列
    - taskID: 取得したいTaskのID
 - Returns: Taskデータ
*/
func getTaskWithID(array :[Task], ID: String) -> Task {
    return array.filter{ $0.getTaskID().contains(ID) }.first!
}
