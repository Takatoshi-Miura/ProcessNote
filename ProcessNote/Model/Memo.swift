//
//  Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

class Memo {
    
    // MARK: - Variable
    
    // 不変
    private var userID: String      // ユーザーID
    private var memoID: Int         // メモID
    private var noteID: Int         // 所属するノートID
    private var measuresID: Int     // 所属する対策ID
    private var created_at: String  // 作成日
    // 可変
    private var detail: String      // メモの内容
    private var updated_at: String  // 更新日
    private var isDeleted: Bool     // 削除フラグ
    
    
    // MARK: - Initializer
    
    init() {
        self.userID = ""
        self.memoID = 0
        self.noteID = 0
        self.measuresID = 0
        self.created_at = ""
        self.detail = ""
        self.updated_at = ""
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setMemoID(_ memoID: Int) {
        self.memoID = memoID
    }
    
    func setNoteID(_ noteID: Int) {
        self.noteID = noteID
    }
    
    func setMeasuresID(_ measuresID: Int) {
        self.measuresID = measuresID
    }
    
    func setCreated_at(_ created_at: String) {
        self.created_at = created_at
    }
    
    func setDetail(_ detail: String) {
        self.detail = detail
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
    
    func getMemoID() -> Int {
        return self.memoID
    }
    
    func getNoteID() -> Int {
        return self.noteID
    }
    
    func getMeasuresID() -> Int {
        return self.measuresID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getDetail() -> String {
        return self.detail
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
    
    func getIsDeleted() -> Bool {
        return self.isDeleted
    }
}

