//
//  Note.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

import RealmSwift

class Note: Object {
    
    // MARK: - Variable
    
    // 不変
    @objc dynamic private var userID: String      // ユーザーID
    @objc dynamic private var noteID: String      // ノートID
    @objc dynamic private var created_at: String  // 作成日
    // 可変
    @objc dynamic private var updated_at: String  // 更新日
    @objc dynamic private var isDeleted: Bool     // 削除フラグ
    // 主キー
    override static func primaryKey() -> String? {
        return "noteID"
    }
    
    
    // MARK: - Initializer
    
    override init() {
        self.userID = UserDefaults.standard.object(forKey: "userID") as! String
        self.noteID = NSUUID().uuidString
        self.created_at = getCurrentDate()
        self.updated_at = ""
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setNoteID(_ noteID: String) {
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
    
    func getNoteID() -> String {
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
