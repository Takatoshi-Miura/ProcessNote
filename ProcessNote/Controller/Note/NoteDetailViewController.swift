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
}


class NoteDetailViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var note = Note()
    var memoArray = [Memo]()
    var sectionTitle: [String] = [""]
    var delegate: NoteDetailViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        memoArray = getMemo(noteID: note.getNoteID())
    }
    
    func initNavigationBar() {
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// ノートを削除(Firebaseへの反映はviewDidDisappear)
    @objc func deleteNote() {
        showDeleteAlert(title: "DeleteNoteTitle", message: "DeleteNoteMessage", OKAction: {
            updateNoteIsDeleted(note: self.note)
            for memo in self.memoArray {
                updateMemoIsDeleted(memo: memo)
            }
            self.delegate?.noteDetailVCDeleteNote()
        })
    }
    
    func initTableView() {
        sectionTitle = [""]
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NoteTextViewCell", bundle: nil), forCellReuseIdentifier: "NoteTextViewCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if (selectedIndex != nil) {
//            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
//            // 対策が削除されていれば取り除く
//            let measures = measuresArray[selectedIndex!.row]
//            if measures.getIsDeleted() {
//                measuresArray.remove(at: selectedIndex!.row)
//                tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
//                selectedIndex = nil
//                return
//            }
//            tableView.reloadRows(at: [selectedIndex!], with: .none)
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateNote(note)
            for memo in memoArray {
                updateMemo(memo)
            }
        }
    }

}


extension NoteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
//        return sectionTitle[section]
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoArray.isEmpty {
            return 0
        }
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTextViewCell", for: indexPath) as! NoteTextViewCell
        let memo = memoArray[indexPath.row]
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        cell.setLabelText(task: task, measure: measures, detail: memo)
        cell.memo.isEditable = false
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessibilityIdentifier = "NoteDetailViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
