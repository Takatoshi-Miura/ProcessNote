//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol NoteViewControllerDelegate: AnyObject {
    func noteViewControllerDidTap(_ viewController: NoteViewController)
}


class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath = [0, 0]
    var sectionTitle: [String] = []
    var cellTitle: [[String]] = [[]]
    var delegate: NoteViewControllerDelegate?
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
    }
    
    /**
     NavigationControllerの初期設定
     */
    func initNavigationController() {
        self.title = NSLocalizedString("Note", comment: "")
        setNavigationBarButtonDefault()
    }
    
    /**
     tableViewの初期設定
     */
    func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // タップしたときの選択色を消去
        tableView.deselectRow(at: selectedIndex as IndexPath, animated: true)
    }
    
    
    // MARK: - NavigationBarAction
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            setNavigationBarButtonIsEditing()
        } else {
            setNavigationBarButtonDefault()
        }
        tableView.isEditing = editing
        tableView.reloadData()
    }
    
    /**
     通常時のNavigationBar設定
     */
    func setNavigationBarButtonDefault() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote(_:)))
        setNavigationBarButton(left: [editButtonItem], right: [addButton])
    }
    
    /**
     編集時のNavigationBar設定
     */
    func setNavigationBarButtonIsEditing() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNotes(_:)))
        setNavigationBarButton(left: [editButtonItem], right: [deleteButton])
    }
    
    /**
     NavigationBarにボタンをセット
      - Parameters:
        - left: 左側に表示するUIBarButtonItem
        - right: 右側に表示するUIBarButtonItem
     */
    func setNavigationBarButton(left leftBarItems: [UIBarButtonItem], right rightBarItems: [UIBarButtonItem]) {
        navigationItem.leftBarButtonItems = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    /**
     ノートを追加
     */
    @objc func addNote(_ sender: UIBarButtonItem) {
        // TODO: ノート追加画面への遷移処理
    }
    
    /**
     ノートを複数削除
     */
    @objc func deleteNotes(_ sender: UIBarButtonItem) {
        // TODO: ノートの複数削除処理
    }
    
    
    // MARK: - 【Delegate】TableViewController

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellTitle[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    

}
