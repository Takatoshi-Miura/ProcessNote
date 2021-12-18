//
//  SyncManager+Note.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//


/**
 ノートを同期
 - Parameters:
    - completion: 完了処理
 */
func syncNote(completion: @escaping () -> ()) {
    // Realmのノートを全取得
    let realmNoteArray: [Note] = getAllNoteRealm()
    
    // Firebaseのノートを全取得
    getAllNote(completion: {
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseNoteIDArray = getNoteIDArray(array: firebaseNoteArray)
        let realmNoteIDArray = getNoteIDArray(array: realmNoteArray)
        let onlyRealmID = realmNoteIDArray.subtracting(firebaseNoteIDArray)
        let onlyFirebaseID = firebaseNoteIDArray.subtracting(realmNoteIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存
        for noteID in onlyRealmID {
            let note = getNoteWithID(array: realmNoteArray, ID: noteID)
            saveNote(note: note, completion: {})
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        for noteID in onlyFirebaseID {
            let note = getNoteWithID(array: firebaseNoteArray, ID: noteID)
            if !createRealm(object: note) {
                return
            }
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        let commonID = realmNoteIDArray.subtracting(onlyRealmID)
        for noteID in commonID {
            let realmNote = getNoteWithID(array: realmNoteArray, ID: noteID)
            let firebaseNote = getNoteWithID(array: firebaseNoteArray, ID: noteID)
            let realmDate = dateFromString(realmNote.getUpdated_at())
            let firebaseDate = dateFromString(firebaseNote.getUpdated_at())
            
            if realmDate > firebaseDate {
                // Realmデータの方が新しい
                saveNote(note: realmNote, completion: {})
            } else if firebaseDate > realmDate  {
                // Firebaseデータの方が新しい
                if !createRealm(object: firebaseNote) {
                    return
                }
            }
        }
        completion()
    })
}

/**
 Note配列からnoteID配列を作成
 - Parameters:
    - array: Note配列
 - Returns: noteID配列
 */
func getNoteIDArray(array: [Note]) -> [String] {
    var noteIDArray: [String] = []
    for note in array {
        noteIDArray.append(note.getNoteID())
    }
    return noteIDArray
}

/**
 Note配列からNoteを取得(noteID指定)
 - Parameters:
    - array: 検索対象のNote配列
    - noteID: 取得したいNoteのID
 - Returns: Noteデータ
*/
func getNoteWithID(array :[Note], ID: String) -> Note {
    return array.filter{ $0.getNoteID().contains(ID) }.first!
}
