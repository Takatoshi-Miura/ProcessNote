//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol NoteViewControllerDelegate: AnyObject {
    // ハンバーガーメニューボタンタップ時の処理
    func noteVCHumburgerMenuButtonDidTap(_ viewController: NoteViewController)
    // ノート追加ボタンタップ時の処理
    func noteVCAddButtonDidTap(_ viewController: NoteViewController)
    // ノートタップ時の処理
    func noteVCNoteDidTap(note: Note)
}


class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath?
    var sectionTitle: [String] = [""]
    var cellTitle: [[String]] = [[]]
    var delegate: NoteViewControllerDelegate?
    var noteArray = [Note]()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        addRightSwipeGesture()
        noteArray = getNoteArrayForNoteView()
    }
    
    func initNavigationController() {
        self.title = NSLocalizedString("Note", comment: "")
        
        var menuButton: UIBarButtonItem
        let image = UITraitCollection.current.userInterfaceStyle == .dark ? UIImage(named: "humburger_menu_white")! : UIImage(named: "humburger_menu_black")!
        menuButton = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                                     style: .plain,
                                     target: self,
                                     action: #selector(openHumburgerMenu(_:)))
        navigationItem.leftBarButtonItems = [menuButton]
    }
    
    /// ハンバーガーメニューを表示
    @objc func openHumburgerMenu(_ sender: UIBarButtonItem) {
        self.delegate?.noteVCHumburgerMenuButtonDidTap(self)
    }
    
    /// 右スワイプでハンバーガーメニューを開く
    func addRightSwipeGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(openHumburgerMenu(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            showIndicator(message: "ServerCommunication")
            syncDatabase(completion: {
                self.noteArray = getNoteArrayForNoteView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            noteArray = getNoteArrayForNoteView()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (selectedIndex != nil) {
            // 削除されている場合は一覧から取り除く
            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
            let note = noteArray[selectedIndex!.row]
            if note.getIsDeleted() {
                noteArray.remove(at: selectedIndex!.row)
                tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
                selectedIndex = nil
                return
            }
            tableView.reloadRows(at: [selectedIndex!], with: .none)
            selectedIndex = nil
        }
    }
    
    /// ノート追加
    @IBAction func addButtonTap(_ sender: Any) {
        if getAllMeasures(isDeleted: false).isEmpty {
            showErrorAlert(message: "EmptyMeasures")
            return
        }
        self.delegate?.noteVCAddButtonDidTap(self)
    }
    
    /**
     ノートを挿入
     - Parameters:
        - note: 挿入するノート
     */
    func insertNote(note: Note) {
        let index: IndexPath = [0, 0]
        noteArray.append(note)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
}
    

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {

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
        if noteArray.isEmpty {
            return 0
        }
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = noteArray[indexPath.row].getCreated_at()
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let note = noteArray[indexPath.row]
        delegate?.noteVCNoteDidTap(note: note)
    }

}
