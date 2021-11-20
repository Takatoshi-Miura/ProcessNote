//
//  Note.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

class Note {
    
    // MARK: - Variable
    
    // 不変
    private var userID: String      // ユーザーID
    private var noteID: Int         // ノートID
    private var created_at: String  // 作成日
    // 可変
    private var updated_at: String  // 更新日
    private var isDeleted: Bool     // 削除フラグ
    
    
    // MARK: - Initializer
    
    init() {
        self.userID = ""
        self.noteID = 0
        self.created_at = ""
        self.updated_at = ""
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setNoteID(_ noteID: Int) {
        self.noteID = noteID
    }
    
    func setCreated_at(_ created_at: String) {
        self.created_at = created_at
    }
    
    func setUpdated_at(_ updated_at: String) {
        self.updated_at = updated_at
    }
    
    func setIsDeleted(_ isDeleted: Bool) {
        self.isDeleted = isDeleted
    }
    
    
    // MARK: - Getter
    
    func getUserID() -> String {
        return self.userID
    }
    
    func getNoteID() -> Int {
        return self.noteID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
    
    func getIsDeleted() -> Bool {
        return self.isDeleted
    }
}
