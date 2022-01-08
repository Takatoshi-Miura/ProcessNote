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
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    var memo = Memo()
    var delegate: MemoDetailViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemGray6
        initNavigationBar()
        initLabel()
        initTextView()
    }
    
    func initNavigationBar() {
        self.title = TITLE_EDIT_NOTE
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMemo))
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// メモを削除(Firebaseへの反映はviewDidDisappear)
    @objc func deleteMemo() {
        showDeleteAlert(title: TITLE_DELETE_NOTE, message: MESSAGE_DELETE_NOTE, OKAction: {
            updateMemoIsDeleted(memo: self.memo)
            self.delegate?.memoDetailVCDeleteMemo()
        })
    }
    
    func initLabel() {
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        taskNameLabel.text = task.getTitle()
        measuresLabel.text = "\(TITLE_MEASURES)：\(measures.getTitle())"
    }
    
    func initTextView() {
        memoTextView.delegate = self
        memoTextView.text = memo.getDetail()
        // 余白を追加
        memoTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        memoTextView.sizeToFit()
        // キーボードに完了ボタンを追加
        memoTextView.inputAccessoryView = createToolBar(#selector(completeAction))
    }
    
    /// キーボードを閉じる
    @objc func completeAction() {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateMemo(memo)
        }
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

