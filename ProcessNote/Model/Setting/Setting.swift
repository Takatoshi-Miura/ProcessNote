//
//  Setting.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

class Setting {
    
    // MARK: - Variable
    
    // 不変
    private var userID: String              // ユーザーID
    private var created_at: String          // 作成日
    // 可変
    private var theme: Int                  // テーマ(0:ホワイト, 1:ダーク, )
    private var enableNotification: Bool    // 通知の許可
    private var noteViewerType: Int         // ノートタブの設定(0:一覧表示, 1:ノート単体表示)
    private var updated_at: String          // 更新日
    
    
    // MARK: - Initializer
    
    init() {
        self.userID = ""
        self.created_at = ""
        self.theme = 0
        self.enableNotification = false
        self.noteViewerType = 0
        self.updated_at = ""
    }
    
    
    // MARK: - Setter
    
    func setUserID(_ userID: String) {
        self.userID = userID
    }
    
    func setCreated_at(_ created_at: String) {
        self.created_at = created_at
    }
    
    func setTheme(_ theme: Int) {
        self.theme = theme
    }
    
    func setEnableNotification(_ enableNotification: Bool) {
        self.enableNotification = enableNotification
    }
    
    func setNoteViewerType(_ noteViewerType: Int) {
        self.noteViewerType = noteViewerType
    }
    
    func setUpdated_at(_ updated_at: String) {
        self.updated_at = updated_at
    }
    
    
    // MARK: - Getter
    
    func getUserID() -> String {
        return self.userID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getTheme() -> Int {
        return self.theme
    }
    
    func getEnableNotification() -> Bool {
        return self.enableNotification
    }
    
    func getNoteViewerType() -> Int {
        return self.noteViewerType
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
}

