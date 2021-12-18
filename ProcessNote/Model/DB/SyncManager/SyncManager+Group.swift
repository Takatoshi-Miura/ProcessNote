//
//  SyncManager+Group.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//


/**
 グループを同期
 - Parameters:
    - completion: 完了処理
 */
func syncGroup(completion: @escaping () -> ()) {
    // Realmのグループを全取得
    let realmGroupArray: [Group] = getAllGroupRealm()
    
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

