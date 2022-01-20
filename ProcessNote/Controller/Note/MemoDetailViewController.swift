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
    @IBOutlet weak var groupColorView: UIImageView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoTextViewBottom: NSLayoutConstraint!
    private var safeAreaInsetsBottom: CGFloat = 0
    var memo = Memo()
    var delegate: MemoDetailViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemGray6
        initNavigationBar()
        initGroupColor()
        initLabel()
        initTextView()
        initNotification()
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
    
    func initGroupColor() {
        let group = getGroup(memo: memo)
        groupColorView.backgroundColor = color[group.getColor()]
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
        memoTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        memoTextView.sizeToFit()
        memoTextView.inputAccessoryView = createToolBar(#selector(completeAction))
        memoTextView.isEditable = false // URLリンクを機能させるため基本は編集不可
    }
    
    /// キーボードを閉じる
    @objc func completeAction() {
        memoTextView.isEditable = false
        self.view.endEditing(true)
    }
    
    @IBAction func actionTapMemoTextView(_ sender: Any) {
        self.memoTextView.isEditable = true
        self.memoTextView.becomeFirstResponder()
    }
    
    func initNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        // キーボードで入力欄が隠れるのを防止
        guard let keyboardHeight = notification.keyboardHeight,
              let keyboardAnimationDuration = notification.keybaordAnimationDuration,
              let KeyboardAnimationCurve = notification.keyboardAnimationCurve
        else { return }
        
        UIView.animate(withDuration: keyboardAnimationDuration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: KeyboardAnimationCurve))
        {
            let tabBarController = UITabBarController()
            let tabBarHeight = tabBarController.tabBar.frame.size.height
            self.memoTextViewBottom.constant = -keyboardHeight + tabBarHeight + self.safeAreaInsetsBottom
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard let keyboardAnimationDuration = notification.keybaordAnimationDuration,
              let KeyboardAnimationCurve = notification.keyboardAnimationCurve
        else { return }
        
        UIView.animate(withDuration: keyboardAnimationDuration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: KeyboardAnimationCurve))
        {
            self.memoTextViewBottom.constant = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // SafeAreaの余白を取得
        guard let root = UIApplication.shared.windows.filter({$0.isKeyWindow}).first!.rootViewController else {
            return
        }
        if #available(iOS 11.0, *) {
            self.safeAreaInsetsBottom = root.view.safeAreaInsets.bottom
        } else {
            self.safeAreaInsetsBottom = root.bottomLayoutGuide.length
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateMemo(memo: memo)
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

