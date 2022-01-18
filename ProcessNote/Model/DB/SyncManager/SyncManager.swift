//
//  SyncManager.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

import UIKit


/**
 RaalmとFirebaseのデータを同期
 - Parameters:
    - completion: 完了処理
 */
func syncDatabase(completion: @escaping () -> ()) {
    // Realmはスレッドを超えてはいけないため同期的に処理を行う
    // 各データ毎に専用のスレッドを作成して処理を行う
    var completionNumber = 0
        
    print("グループ同期開始")
    DispatchQueue.global(qos: .default).sync {
        syncGroup(completion: {
            print("グループ同期終了")
            completionNumber += 1
            syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
        })
    }
    
    print("課題同期開始")
    DispatchQueue.global(qos: .default).sync {
        syncTask(completion: {
            print("課題同期終了")
            completionNumber += 1
            syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
        })
    }
    
    print("対策同期開始")
    DispatchQueue.global(qos: .default).sync {
        syncMeasures(completion: {
            print("対策同期終了")
            completionNumber += 1
            syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
        })
    }
    
    print("メモ同期開始")
    DispatchQueue.global(qos: .default).sync {
        syncMemo(completion: {
            print("メモ同期終了")
            completionNumber += 1
            syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
        })
    }
}

/**
 RaalmとFirebaseのデータ同期終了後の処理
 - Parameters:
    - completion: 完了処理
    - completionNumber: タスク完了数
 */
func syncDatabaseCompletion(completion: @escaping () -> (), completionNumber: Int) {
    // グループ、課題、対策、メモ全ての同期が終了した場合のみ完了処理を実行
    if completionNumber == 4 {
        completion()
    }
}
