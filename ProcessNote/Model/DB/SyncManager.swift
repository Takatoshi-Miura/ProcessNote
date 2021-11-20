//
//  SyncManager.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

/**
 RaalmとFirebaseのデータを同期
 - Parameters:
    - completion: 完了処理
 */
func syncDatabase(completion: @escaping () -> ()) {
    syncGroup(completion: {
        syncTask(completion: {
            syncMeasures(completion: {
                completion()
            })
        })
    })
}



// MARK: - Group

/**
 グループを同期
 - Parameters:
    - completion: 完了処理
 */
func syncGroup(completion: @escaping () -> ()) {
    // Realmのグループを全取得
    let realmGroupArray: [Group] = selectAllGroupRealm()
    
    // Firebaseのグループを全取得
    getAllGroup(completion: {
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseGroupIDArray = getGroupIDArray(array: firebaseGroupArray)
        let realmGroupIDArray = getGroupIDArray(array: realmGroupArray)
        let onlyRealmID = realmGroupIDArray.subtracting(firebaseGroupIDArray)
        let onlyFirebaseID = firebaseGroupIDArray.subtracting(realmGroupIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存
        for groupID in onlyRealmID {
            let group = getGroupWithID(array: realmGroupArray, ID: groupID)
            saveGroup(group: group, completion: {})
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        for groupID in onlyFirebaseID {
            let group = getGroupWithID(array: firebaseGroupArray, ID: groupID)
            if !createRealm(object: group) {
                return
            }
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        let commonID = realmGroupIDArray.subtracting(onlyRealmID)
        for groupID in commonID {
            let realmGroup = getGroupWithID(array: realmGroupArray, ID: groupID)
            let firebaseGroup = getGroupWithID(array: firebaseGroupArray, ID: groupID)
            let realmDate = dateFromString(realmGroup.getUpdated_at())
            let firebaseDate = dateFromString(firebaseGroup.getUpdated_at())
            
            if realmDate > firebaseDate {
                // Realmデータの方が新しい
                saveGroup(group: realmGroup, completion: {})
            } else if firebaseDate > realmDate  {
                // Firebaseデータの方が新しい
                if !createRealm(object: firebaseGroup) {
                    return
                }
            }
        }
        completion()
    })
}

/**
 Group配列からgroupID配列を作成
 - Parameters:
    - array: Group配列
 - Returns: groupID配列
 */
func getGroupIDArray(array: [Group]) -> [String] {
    var groupIDArray: [String] = []
    for group in array {
        groupIDArray.append(group.getGroupID())
    }
    return groupIDArray
}

/**
 Group配列からGroupを取得(groupID指定)
 - Parameters:
    - array: 検索対象のGroup配列
    - groupID: 取得したいGroupのID
 - Returns: Groupデータ
*/
func getGroupWithID(array :[Group], ID: String) -> Group {
    return array.filter{ $0.getGroupID().contains(ID) }.first!
}


// MARK: - Task

/**
 課題を同期
 - Parameters:
    - completion: 完了処理
 */
func syncTask(completion: @escaping () -> ()) {
    // Realmの課題を全取得
    let realmTaskArray: [Task] = selectAllTaskRealm()
    
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


// MARK: - Measures

/**
 対策を同期
 - Parameters:
    - completion: 完了処理
 */
func syncMeasures(completion: @escaping () -> ()) {
    // Realmの対策を全取得
    let realmMeasuresArray: [Measures] = selectAllMeasuresRealm()
    
    // Firebaseの対策を全取得
    getAllMeasures(completion: {
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseMeasuresIDArray = getMeasuresIDArray(array: firebaseMeasuresArray)
        let realmMeasuresIDArray = getMeasuresIDArray(array: realmMeasuresArray)
        let onlyRealmID = realmMeasuresIDArray.subtracting(firebaseMeasuresIDArray)
        let onlyFirebaseID = firebaseMeasuresIDArray.subtracting(realmMeasuresIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存
        for measuresID in onlyRealmID {
            let measures = getMeasuresWithID(array: realmMeasuresArray, ID: measuresID)
            saveMeasures(measures: measures, completion: {})
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        for measuresID in onlyFirebaseID {
            let measures = getMeasuresWithID(array: firebaseMeasuresArray, ID: measuresID)
            if !createRealm(object: measures) {
                return
            }
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        let commonID = realmMeasuresIDArray.subtracting(onlyRealmID)
        for measuresID in commonID {
            let realmMeasures = getMeasuresWithID(array: realmMeasuresArray, ID: measuresID)
            let firebaseMeasures = getMeasuresWithID(array: firebaseMeasuresArray, ID: measuresID)
            let realmDate = dateFromString(realmMeasures.getUpdated_at())
            let firebaseDate = dateFromString(firebaseMeasures.getUpdated_at())
            
            if realmDate > firebaseDate {
                // Realmデータの方が新しい
                saveMeasures(measures: realmMeasures, completion: {})
            } else if firebaseDate > realmDate  {
                // Firebaseデータの方が新しい
                if !createRealm(object: firebaseMeasures) {
                    return
                }
            }
        }
        completion()
    })
}

/**
 Measures配列からmeasuresID配列を作成
 - Parameters:
    - array: Task配列
 - Returns: measuresID配列
 */
func getMeasuresIDArray(array: [Measures]) -> [String] {
    var measuresIDArray: [String] = []
    for measures in array {
        measuresIDArray.append(measures.getMeasuresID())
    }
    return measuresIDArray
}

/**
 Measures配列からMeasuresを取得(measuresID指定)
 - Parameters:
    - array: 検索対象のMeasures配列
    - measuresID: 取得したいMeasuresのID
 - Returns: Measuresデータ
*/
func getMeasuresWithID(array :[Measures], ID: String) -> Measures {
    return array.filter{ $0.getMeasuresID().contains(ID) }.first!
}
