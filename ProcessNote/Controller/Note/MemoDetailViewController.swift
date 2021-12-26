//
//  MemoDetailViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/10.
//

import UIKit


protocol MemoDetailViewControllerDelegate: AnyObject {
    // メモ削除時の処理
    func memoDetailVCDeleteMemo()
}


class MemoDetailViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var memo = Memo()
    var delegate: MemoDetailViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
    }
    
    func initNavigationBar() {
        self.title = TITLE_EDIT_MEMO
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMemo))
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// メモを削除(Firebaseへの反映はviewDidDisappear)
    @objc func deleteMemo() {
        showDeleteAlert(title: TITLE_DELETE_MEMO, message: MESSAGE_DELETE_MEMO, OKAction: {
            updateMemoIsDeleted(memo: self.memo)
            self.delegate?.memoDetailVCDeleteMemo()
        })
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NoteTextViewCell", bundle: nil), forCellReuseIdentifier: "NoteTextViewCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateMemo(memo)
        }
    }

}


extension MemoDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTextViewCell", for: indexPath) as! NoteTextViewCell
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        cell.setLabelText(task: task, measure: measures, detail: memo)
        cell.memo.delegate = self
        cell.memo.inputAccessoryView = createToolBar(#selector(completeAction))
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessibilityIdentifier = "NoteDetailViewCell"
        return cell
    }
    
    @objc func completeAction() {
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension MemoDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 差分がなければ何もしない
        if textView.text! == memo.getDetail() {
            return
        }
        
        // メモを更新
        updateMemoDetail(ID: memo.getMemoID(), detail: textView.text!)
    }
}

