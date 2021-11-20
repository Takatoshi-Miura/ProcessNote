//
//  Task.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

import RealmSwift

class Task: Object {
    
    // MARK: - Variable
    
    // 不変
    @objc dynamic private var userID: String      // ユーザーID
    @objc dynamic private var taskID: String      // 課題ID
    @objc dynamic private var created_at: String  // 作成日
    // 可変
    @objc dynamic private var groupID: String     // 所属するグループID
    @objc dynamic private var title: String       // タイトル
    @objc dynamic private var cause: String       // 原因
    @objc dynamic private var order: Int          // 並び順
    @objc dynamic private var updated_at: String  // 更新日
    @objc dynamic private var completed_at: String// 完了日
    @objc dynamic private var isCompleted: Bool   // 解決フラグ
    @objc dynamic private var isDeleted: Bool     // 削除フラグ
    // 主キー
    override static func primaryKey() -> String? {
        return "taskID"
    }
    
    
    // MARK: - Initializer
    
    override init() {
        self.userID = ""
        self.taskID = ""
        self.groupID = ""
        self.created_at = ""
        self.title = ""
        self.cause = ""
        self.order = 0
        self.updated_at = ""
        self.completed_at = ""
        self.isCompleted = false
        self.isDeleted = false
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setTaskID(_ taskID: String) {
        self.taskID = taskID
    }
    
    func setGroupID(_ groupID: String) {
        self.groupID = groupID
    }
    
    func setCreated_at(_ created_at: String) {
        self.created_at = created_at
    }
    
    func setTitle(_ taskTitle: String) {
        self.title = taskTitle
    }
    
    func setCause(_ taskCause: String) {
        self.cause = taskCause
    }
    
    func setOrder(_ order: Int) {
        self.order = order
    }
    
    func setUpdated_at(_ updated_at: String) {
        self.updated_at = updated_at
    }
    
    func setCompleted_at(_ completed_at: String) {
        self.completed_at = completed_at
    }
    
    func setIsCompleted(_ isCompleted: Bool) {
        self.isCompleted = isCompleted
    }
    
    func setIsDeleted(_ isDeleted: Bool) {
        self.isDeleted = isDeleted
    }
    
    /**
     新規作成時に不変の項目をセット
     */
    func setFixedProperty() {
        self.userID = UserDefaults.standard.object(forKey: "userID") as! String
        self.taskID = NSUUID().uuidString
        self.created_at = getCurrentTime()
    }
    
    
    // MARK: - Getter
    
    func getUserID() -> String {
        return self.userID
    }
    
    func getTaskID() -> String {
        return self.taskID
    }
    
    func getGroupID() -> String {
        return self.groupID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getCause() -> String {
        return self.cause
    }
    
    func getOrder() -> Int {
        return self.order
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
    
    func getCompleted_at() -> String {
        return self.completed_at
    }
    
    func getIsCompleted() -> Bool {
        return self.isCompleted
    }
    
    func getIsDeleted() -> Bool {
        return self.isDeleted
    }
}
