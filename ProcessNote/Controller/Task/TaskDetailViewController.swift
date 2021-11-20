//
//  TaskDetailViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var task = Task()
    var sectionTitle: [String] = []
    var measuresArray: [Measures] = []
    enum Section: Int {
        case title = 0
        case cause
        case measures
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        measuresArray = getMeasuresInTask(ID: task.getTaskID())
    }
    
    func initNavigationBar() {
        self.title = NSLocalizedString("TaskDetailTitle", comment: "")
        if !task.getIsCompleted() {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMeasures(_:)))
            navigationItem.rightBarButtonItems = [addButton]
        }
    }
    
    /// 対策を追加
    @objc func addMeasures(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: NSLocalizedString("AddMeasuresTitle", comment: ""),
                                      message: NSLocalizedString("AddMeasuresMessage", comment: ""),
                                      preferredStyle: .alert)
        
        var alertTextField: UITextField?
        alert.addTextField(configurationHandler: {(textField) -> Void in
            alertTextField = textField
        })
        
        let OKAction = UIAlertAction(title: NSLocalizedString("Add", comment: ""),
                                     style: UIAlertAction.Style.default,
                                     handler: {(action: UIAlertAction) in
            if (alertTextField?.text != nil) {
                self.addMeasures(title: alertTextField!.text!)
            } else {
                self.showErrorAlert(message: "EmptyTitle")
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
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
            showErrorAlert(message: "TaskCreateError")
            return
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            saveMeasures(measures: measures, completion: {})
        }
        
        // tableView更新
        let index: IndexPath = [Section.measures.rawValue, measures.getOrder()]
        measuresArray.append(measures)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("Title", comment: ""),
                        NSLocalizedString("Cause", comment: ""),
                        NSLocalizedString("Measures", comment: "")]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateTask(selectTaskRealm(ID: task.getTaskID()))
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
            return cell
        case .cause:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.setText(task.getCause())
            cell.textView.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case .measures:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = measuresArray[indexPath.row].getTitle()
            cell.backgroundColor = UIColor.systemGray6
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
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
            showErrorAlert(message: "EmptyTitle")
            textField.text = task.getTitle()
            return false
        }
        
        // 課題を更新
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
        
        // 課題を更新
        updateTaskCauseRealm(ID: task.getTaskID(), cause: textView.text!)
    }
}
