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
    
    enum Section: Int {
        case title
        case cause
        case measures
    }
    
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
    }
    
    /**
     NavigationBarの初期設定
     */
    func initNavigationBar() {
        self.title = NSLocalizedString("TaskDetailTitle", comment: "")
    }
    
    /**
     tableViewの初期設定
     */
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
        switch section {
        case Section.title.rawValue:
            return 1
        case Section.cause.rawValue:
            return 1
        case Section.measures.rawValue:
            return getMeasuresInTask(ID: task.getTaskID()).count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case Section.title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.setTitle(task.getTitle())
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case Section.cause.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.setText(task.getCause())
            cell.textView.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case Section.measures.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = getMeasuresInTask(ID: task.getTaskID())[indexPath.row].getTitle()
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
