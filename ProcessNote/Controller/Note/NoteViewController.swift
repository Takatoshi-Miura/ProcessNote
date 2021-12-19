//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol NoteViewControllerDelegate: AnyObject {
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
    var noteArray = [[Note]]()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        sectionTitle = getNoteYearAndMonth()
        noteArray = getNoteArrayForNoteView()
    }
    
    func initNavigationController() {
        self.title = NSLocalizedString("Note", comment: "")
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
                self.sectionTitle = getNoteYearAndMonth()
                self.noteArray = getNoteArrayForNoteView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            sectionTitle = getNoteYearAndMonth()
            noteArray = getNoteArrayForNoteView()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (selectedIndex != nil) {
            // 削除されている場合は一覧から取り除く
            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
            let note = noteArray[selectedIndex!.section][selectedIndex!.row]
            if note.getIsDeleted() {
                noteArray[selectedIndex!.section].remove(at: selectedIndex!.row)
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
        
        if !noteArray.isEmpty {
            // 同日のノートがあるなら追加しない
            if note.getCreated_at() == noteArray[0].first!.getCreated_at() {
                return
            }
            
            // セクション追加の必要性の判定(既存ノートと同じ年月かどうか)
            let realmNoteYearMonth = changeDateString(dateString: noteArray[0].first!.getCreated_at(), format: "yyyy-MM-dd", goalFormat: "yyyy-MM")
            let newNoteYearMonth = changeDateString(dateString: note.getCreated_at(), format: "yyyy-MM-dd", goalFormat: "yyyy-MM")
            if newNoteYearMonth == realmNoteYearMonth {
                noteArray[0].insert(note, at: 0)
                tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
            } else {
                sectionTitle.insert(getCreatedYearAndMonth(note: note), at: 0)
                noteArray.insert([note], at: 0)
                tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
            }
        } else {
            // 初めてノートを作成する場合(セクション&ノート追加)
            sectionTitle.insert(getCreatedYearAndMonth(note: note), at: 0)
            noteArray.insert([note], at: 0)
            tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
        }
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
        return noteArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noteDate = noteArray[indexPath.section][indexPath.row].getCreated_at()
        cell.textLabel?.text = changeDateString(dateString: noteDate, format: "yyyy-MM-dd", goalFormat: "MM / dd")
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let note = noteArray[indexPath.section][indexPath.row]
        delegate?.noteVCNoteDidTap(note: note)
    }

}
