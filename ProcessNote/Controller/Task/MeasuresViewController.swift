//
//  MeasuresViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import UIKit


protocol MeasuresViewControllerDelegate: AnyObject {
    // 対策削除時の処理
    func measuresVCDeleteMeasures()
    // メモタップ時の処理
    func measuresVCMemoDidTap(memo: Memo)
}


class MeasuresViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var measures = Measures()
    var sectionTitle: [String] = []
    var memoArray = [Memo]()
    var delegate: MeasuresViewControllerDelegate?
    enum Section: Int {
        case title = 0
        case note
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        memoArray = getMemo(measuresID: measures.getMeasuresID())
    }
    
    func initNavigationBar() {
        self.title = NSLocalizedString("MeasuresTitle", comment: "")
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMeasures))
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    /// 対策とそれに含まれるメモを削除
    @objc func deleteMeasures() {
        showDeleteAlert(title: "DeleteMeasuresTitle", message: "DeleteMeasuresMessage", OKAction: {
            updateMeasuresIsDeleted(measures: self.measures)
            for memo in self.memoArray {
                updateMemoIsDeleted(memo: memo)
            }
            if Network.isOnline() {
                updateMeasures(self.measures)
                for memo in self.memoArray {
                    updateMemo(memo)
                }
            }
            self.delegate?.measuresVCDeleteMeasures()
        })
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("Title", comment: ""), NSLocalizedString("Note", comment: "")]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableView.indexPathForSelectedRow != nil {
            tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateMeasures(measures)
        }
    }
    
}


extension MeasuresViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        switch Section(rawValue: section) {
        case .title:
            return 1
        case .note:
            if memoArray.isEmpty {
                return 0
            }
            return memoArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.setTitle(measures.getTitle())
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "MeasuresViewCell"
            let task = getTask(taskID: measures.getTaskID())
            if task.getIsCompleted() {
                cell.textField.isEnabled = false
            }
            return cell
        case .note:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let memo = memoArray[indexPath.row]
            cell.textLabel?.text = "\(changeDateString(dateString: memo.getCreated_at(), format: "yyyy-MM-dd HH:mm:ss", goalFormat: "yyyy/MM/dd"))\n\(memo.getDetail())"
            cell.backgroundColor = UIColor.systemGray6
            cell.textLabel?.numberOfLines = 0 // 全文表示
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.3))
            separatorView.backgroundColor = UIColor.gray
            cell.addSubview(separatorView)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    @objc func completeAction() {
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .title:
            break
        case .note:
            if !memoArray.isEmpty {
                delegate?.measuresVCMemoDidTap(memo: memoArray[indexPath.row])
            }
            break
        default:
            break
        }
    }
    
}


extension MeasuresViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == measures.getTitle() {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: "EmptyTitle")
            textField.text = measures.getTitle()
            return false
        }
        
        // 対策を更新
        updateMeasuresTitleRealm(ID: measures.getMeasuresID(), title: textField.text!)
        return true
    }
}
