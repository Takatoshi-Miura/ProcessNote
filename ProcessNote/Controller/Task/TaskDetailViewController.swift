//
//  TaskDetailViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

import UIKit


protocol TaskDetailViewControllerDelegate: AnyObject {
    // 課題の完了(未完了)時の処理
    func taskDetailVCCompleteTask(task: Task)
    // 課題削除時の処理
    func taskDetailVCDeleteTask(task: Task)
    // 対策セルタップ時の処理
    func taskDetailVCMeasuresCellDidTap(measures: Measures)
}


class TaskDetailViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    private var sectionTitle: [String] = []
    private var measuresArray: [Measures] = []
    var task = Task()
    var delegate: TaskDetailViewControllerDelegate?
    
    private enum Section: Int {
        case title = 0
        case cause
        case measures
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        addButton.isHidden = task.getIsCompleted() ? true : false
        measuresArray = getMeasuresInTask(ID: task.getTaskID())
    }
    
    func initNavigationBar() {
        self.title = TITLE_TASK_DETAIL
        
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
        let image = task.getIsCompleted() ? UIImage(systemName: "exclamationmark.circle") : UIImage(systemName: "checkmark.circle")
        let completeButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(completeTask))
        navigationItems.append(deleteButton)
        navigationItems.append(completeButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// 課題を削除
    @objc func deleteTask() {
        showDeleteAlert(title: TITLE_DELETE_TASK, message: MESSAGE_DELETE_TASK, OKAction: {
            updateTaskIsDeleted(task: self.task)
            self.delegate?.taskDetailVCDeleteTask(task: self.task)
        })
    }
    
    /// 課題を完了(未完了)にする
    @objc func completeTask() {
        let isCompleted = task.getIsCompleted()
        let message = isCompleted ? MESSAGE_INCOMPLETE_TASK : MESSAGE_COMPLETE_TASK
        showOKCancelAlert(title: TITLE_COMPLETE_TASK, message: message, OKAction: {
            updateTaskIsCompleted(task: self.task, isCompleted: !isCompleted)
            self.delegate?.taskDetailVCCompleteTask(task: self.task)
        })
    }
    
    @IBAction func addButtonTap(_ sender: Any) {
        // 対策を追加
        let alert = UIAlertController(title: TITLE_ADD_MEASURES,
                                      message: MESSAGE_ADD_MEASURES,
                                      preferredStyle: .alert)
        
        var alertTextField: UITextField?
        alert.addTextField(configurationHandler: {(textField) -> Void in
            alertTextField = textField
        })
        
        let OKAction = UIAlertAction(title: TITLE_ADD,
                                     style: UIAlertAction.Style.default,
                                     handler: {(action: UIAlertAction) in
            if (alertTextField?.text == nil || alertTextField?.text == "") {
                self.showErrorAlert(message: MESSAGE_EMPTY_TITLE)
            } else {
                self.addMeasures(title: alertTextField!.text!)
            }
        })
        
        let cancelAction = UIAlertAction(title: TITLE_CANCEL,
                                         style: UIAlertAction.Style.cancel,
                                         handler: nil)
        
        let actions = [OKAction, cancelAction]
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    func addMeasures(title: String) {
        // 対策データを作成＆保存
        let measures = Measures()
        measures.setFixedProperty()
        measures.setTaskID(task.getTaskID())
        measures.setTitle(title)
        measures.setOrder(getMeasuresInTask(ID: task.getTaskID()).count)
        measures.setUpdated_at(measures.getCreated_at())
        if !createRealm(object: measures) {
            showErrorAlert(message: MESSAGE_TASK_CREATE_ERROR)
            return
        }
        if Network.isOnline() {
            saveMeasures(measures: measures, completion: {})
        }
        
        // tableView更新
        let index: IndexPath = [Section.measures.rawValue, measures.getOrder()]
        measuresArray.append(measures)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
    func initTableView() {
        sectionTitle = [TITLE_TITLE, TITLE_CAUSE, TITLE_MEASURES]
        tableView.isEditing = true  // 対策セルの常時並び替え許可
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 対策が削除されていれば取り除く
            let measures = measuresArray[selectedIndex.row]
            if measures.getIsDeleted() {
                measuresArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateTask(task: task)
            for measures in measuresArray {
                updateMeasures(measures: measures)
            }
        }
    }
}


extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == Section.measures.rawValue) && !task.getIsCompleted() {
            return true // 対策セルのみ編集可能
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == Section.measures.rawValue) {
            return true // 対策セルのみ並び替え可能
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 対策の並び順を保存
        let measures = measuresArray[sourceIndexPath.row]
        measuresArray.remove(at: sourceIndexPath.row)
        measuresArray.insert(measures, at: destinationIndexPath.row)
        updateMeasuresOrderRealm(measuresArray: measuresArray)
    }
    
    func tableView(_ tableView:UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.section != sourceIndexPath.section) {
            return sourceIndexPath  // セクションを超えた並び替え禁止
        }
        return proposedDestinationIndexPath;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .title:
            return 1
        case .cause:
            return 1
        case .measures:
            if measuresArray.isEmpty {
                return 0
            } else {
                return measuresArray.count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.setTitle(task.getTitle())
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            if task.getIsCompleted() {
                cell.textField.isEnabled = false
            }
            return cell
        case .cause:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.setText(task.getCause())
            cell.textView.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            if task.getIsCompleted() {
                cell.textView.isEditable = false
                cell.textView.isSelectable = false
            }
            return cell
        case .measures:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = measuresArray[indexPath.row].getTitle()
            cell.backgroundColor = UIColor.systemGray6
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
        // 対策画面へ遷移
        if indexPath.section == Section.measures.rawValue {
            let measures = measuresArray[indexPath.row]
            delegate?.taskDetailVCMeasuresCellDidTap(measures: measures)
        }
    }
}


extension TaskDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == task.getTitle() {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: MESSAGE_EMPTY_TITLE)
            textField.text = task.getTitle()
            return false
        }
        
        updateTaskTitleRealm(ID: task.getTaskID(), title: textField.text!)
        return true
    }
}


extension TaskDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 差分がなければ何もしない
        if textView.text! == task.getCause() {
            return
        }
        
        updateTaskCauseRealm(ID: task.getTaskID(), cause: textView.text!)
    }
}
