//
//  Measures.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

import RealmSwift

class Measures: Object {
    
    // MARK: - Variable
    
    // 不変
    @objc dynamic private var userID: String      // ユーザーID
    @objc dynamic private var measuresID: String  // 対策ID
    @objc dynamic private var taskID: String      // 所属する課題ID
    @objc dynamic private var created_at: String  // 作成日
    // 可変
    @objc dynamic private var title: String       // タイトル
    @objc dynamic private var order: Int          // 並び順
    @objc dynamic private var updated_at: String  // 更新日
    @objc dynamic private var isDeleted: Bool     // 削除フラグ
    // 主キー
    override static func primaryKey() -> String? {
        return "measuresID"
    }
    
    
    // MARK: - Initializer
    
    override init() {
        self.userID = ""
        self.taskID = ""
        self.measuresID = ""
        self.created_at = ""
        self.title = ""
        self.order = 0
        self.updated_at = ""
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setMeasuresID(_ measuresID: String) {
        self.measuresID = measuresID
    }
    
    func setTaskID(_ taskID: String) {
        self.taskID = taskID
    }
    
    func setCreated_at(_ created_at: String) {
        self.created_at = created_at
    }
    
    func setTitle(_ taskTitle: String) {
        self.title = taskTitle
    }
    
    func setOrder(_ order: Int) {
        self.order = order
    }
    
    func setUpdated_at(_ updated_at: String) {
        self.updated_at = updated_at
    }
    
    func setIsDeleted(_ isDeleted: Bool) {
        self.isDeleted = isDeleted
    }
    
    /**
     新規作成時に不変の項目をセット
     */
    func setFixedProperty() {
        self.userID = UserDefaults.standard.object(forKey: "userID") as! String
        self.measuresID = NSUUID().uuidString
        self.created_at = getCurrentTime()
    }
    
    
    // MARK: - Getter
    
    func getUserID() -> String {
        return self.userID
    }
    
    func getMeasuresID() -> String {
        return self.measuresID
    }
    
    func getTaskID() -> String {
        return self.taskID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getOrder() -> Int {
        return self.order
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
    
    func getIsDeleted() -> Bool {
        return self.isDeleted
    }
}
