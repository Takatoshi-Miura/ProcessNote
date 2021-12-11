//
//  NoteDetailViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/05.
//

import UIKit


protocol NoteDetailViewControllerDelegate: AnyObject {
    // ノート削除時の処理
    func noteDetailVCDeleteNote()
    // メモタップ時の処理
    func noteDetailVCMemoCellDidTap(memo: Memo)
}


class NoteDetailViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var note = Note()
    var memoArray = [[Memo]]()
    var groupArray = [Group]()
    var sectionTitle = [""]
    private var selectedIndex: IndexPath?
    var delegate: NoteDetailViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        groupArray = getGroupArrayForNoteDetailView(noteID: note.getNoteID())
        memoArray = getMemo(noteID: note.getNoteID(), groupArray: groupArray)
    }
    
    func initNavigationBar() {
        self.title = note.getCreated_at()
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// ノートを削除(Firebaseへの反映はviewDidDisappear)
    @objc func deleteNote() {
        showDeleteAlert(title: "DeleteNoteTitle", message: "DeleteNoteMessage", OKAction: {
            updateNoteIsDeleted(note: self.note)
            for memos in self.memoArray {
                for memo in memos {
                    updateMemoIsDeleted(memo: memo)
                }
            }
            self.delegate?.noteDetailVCDeleteNote()
        })
    }
    
    func initTableView() {
        sectionTitle = [""]
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NoteDetailViewCell", bundle: nil), forCellReuseIdentifier: "NoteDetailViewCell")
        tableView.register(UINib(nibName: String(describing: NoteGroupHeaderView.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: String(describing: NoteGroupHeaderView.self))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (selectedIndex != nil) {
            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
            // メモが削除されていれば取り除く
            let memo = memoArray[selectedIndex!.section][selectedIndex!.row]
            if memo.getIsDeleted() {
                memoArray[selectedIndex!.section].remove(at: selectedIndex!.row)
                tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
                selectedIndex = nil
                return
            }
            tableView.reloadRows(at: [selectedIndex!], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateNote(note)
            for memos in memoArray {
                for memo in memos {
                    updateMemo(memo)
                }
            }
        }
    }

}


extension NoteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: NoteGroupHeaderView.self))
        if let headerView = view as? NoteGroupHeaderView {
            headerView.setProperty(group: groupArray[section])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: NoteGroupHeaderView.self))
        if let headerView = view as? NoteGroupHeaderView {
            return headerView.bounds.height
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoArray[section].isEmpty {
            return 0
        }
        return memoArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteDetailViewCell", for: indexPath) as! NoteDetailViewCell
        let memo = memoArray[indexPath.section][indexPath.row]
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        cell.setLabelText(task: task, measure: measures, detail: memo)
        cell.accessibilityIdentifier = "NoteDetailViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let memo = memoArray[indexPath.section][indexPath.row]
        delegate?.noteDetailVCMemoCellDidTap(memo: memo)
    }
    
}
