//
//  SyncManager+Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//


/**
 メモを同期
 - Parameters:
    - completion: 完了処理
 */
func syncMemo(completion: @escaping () -> ()) {
    // Realmのメモを全取得
    let realmMemoArray: [Memo] = getAllMemoRealm()
    
    // Firebaseのノートを全取得
    getAllMemo(completion: {
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseMemoIDArray = getMemoIDArray(array: firebaseMemoArray)
        let realmMemoIDArray = getMemoIDArray(array: realmMemoArray)
        let onlyRealmID = realmMemoIDArray.subtracting(firebaseMemoIDArray)
        let onlyFirebaseID = firebaseMemoIDArray.subtracting(realmMemoIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存
        for memoID in onlyRealmID {
            let memo = getMemoWithID(array: realmMemoArray, ID: memoID)
            saveMemo(memo: memo, completion: {})
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        for memoID in onlyFirebaseID {
            let memo = getMemoWithID(array: firebaseMemoArray, ID: memoID)
            if !createRealm(object: memo) {
                return
            }
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        let commonID = realmMemoIDArray.subtracting(onlyRealmID)
        for memoID in commonID {
            let realmMemo = getMemoWithID(array: realmMemoArray, ID: memoID)
            let firebaseMemo = getMemoWithID(array: firebaseMemoArray, ID: memoID)
            let realmDate = dateFromString(realmMemo.getUpdated_at())
            let firebaseDate = dateFromString(firebaseMemo.getUpdated_at())
            
            if realmDate > firebaseDate {
                // Realmデータの方が新しい
                saveMemo(memo: realmMemo, completion: {})
            } else if firebaseDate > realmDate  {
                // Firebaseデータの方が新しい
                if !createRealm(object: firebaseMemo) {
                    return
                }
            }
        }
        completion()
    })
}

/**
 Memo配列からmemoID配列を作成
 - Parameters:
    - array: Memo配列
 - Returns: memoID配列
 */
func getMemoIDArray(array: [Memo]) -> [String] {
    var memoIDArray: [String] = []
    for memo in array {
        memoIDArray.append(memo.getMemoID())
    }
    return memoIDArray
}

/**
 Memo配列からMemoを取得(memoID指定)
 - Parameters:
    - array: 検索対象のMemo配列
    - memoID: 取得したいMemoのID
 - Returns: Noteデータ
*/
func getMemoWithID(array :[Memo], ID: String) -> Memo {
    return array.filter{ $0.getMemoID().contains(ID) }.first!
}

