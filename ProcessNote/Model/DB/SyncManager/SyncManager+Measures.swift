//
//  SyncManager+Measures.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//


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
