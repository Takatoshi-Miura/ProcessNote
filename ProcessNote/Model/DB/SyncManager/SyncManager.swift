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
