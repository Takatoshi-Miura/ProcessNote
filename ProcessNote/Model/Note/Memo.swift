//
//  Memo.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

import RealmSwift

class Memo: Object {
    
    // MARK: - Variable
    
    // 不変
    @objc dynamic private var userID: String      // ユーザーID
    @objc dynamic private var memoID: String      // メモID
    @objc dynamic private var noteID: String      // 所属するノートID
    @objc dynamic private var measuresID: String  // 所属する対策ID
    @objc dynamic private var created_at: String  // 作成日
    // 可変
    @objc dynamic private var detail: String      // メモの内容
    @objc dynamic private var updated_at: String  // 更新日
    @objc dynamic private var isDeleted: Bool     // 削除フラグ
    // 主キー
    override static func primaryKey() -> String? {
        return "memoID"
    }
    
    
    // MARK: - Initializer
    
    override init() {
        self.userID = UserDefaults.standard.object(forKey: "userID") as! String
        self.memoID = NSUUID().uuidString
        self.noteID = ""
        self.measuresID = ""
        self.created_at = getCurrentTime()
        self.detail = ""
        self.updated_at = ""
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setMemoID(_ memoID: String) {
        self.memoID = memoID
    }
    
    func setNoteID(_ noteID: String) {
        self.noteID = noteID
    }
    
    func setMeasuresID(_ measuresID: String) {
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
    
    func getMemoID() -> String {
        return self.memoID
    }
    
    func getNoteID() -> String {
        return self.noteID
    }
    
    func getMeasuresID() -> String {
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

