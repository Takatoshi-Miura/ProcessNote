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
        tableView.register(UINib(nibName: "NoteTextViewCell", bundle: nil), forCellReuseIdentifier: "NoteTextViewCell")
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
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return groupArray[section].getTitle()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTextViewCell", for: indexPath) as! NoteTextViewCell
        let memo = memoArray[indexPath.section][indexPath.row]
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        cell.setLabelText(task: task, measure: measures, detail: memo)
        cell.memo.isEditable = false
        cell.accessibilityIdentifier = "NoteDetailViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let memo = memoArray[indexPath.section][indexPath.row]
        delegate?.noteDetailVCMemoCellDidTap(memo: memo)
    }
    
}
