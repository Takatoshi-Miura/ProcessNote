//
//  CompletedTaskViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/20.
//

import UIKit


protocol CompletedTaskViewControllerDelegate: AnyObject {
    // 課題セルタップ時の処理
    func completedTaskVCTaskCellDidTap(task: Task)
}


class CompletedTaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath?
    var taskArray: [Task] = [Task]()
    var groupID: String?
    var delegate: CompletedTaskViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        taskArray = getTasksInGroup(ID: groupID!, isCompleted: true)
    }
    
    func initNavigationController() {
        self.title = NSLocalizedString("CompletedTask", comment: "")
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: String(describing: GroupHeaderView.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: String(describing: GroupHeaderView.self))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// データの同期処理
    @objc func syncData() {
        if tableView.isEditing {
            tableView.refreshControl?.endRefreshing()
            return
        }
        if Network.isOnline() {
            showIndicator(message: "ServerCommunication")
            syncDatabase(completion: {
                self.taskArray = getTasksInGroup(ID: self.groupID!, isCompleted: true)
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            taskArray = getTasksInGroup(ID: groupID!, isCompleted: true)
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (selectedIndex != nil) {
            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
        }
    }
}


extension CompletedTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 編集許可
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 左スワイプで課題を削除
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteAlert(title: "DeleteTaskTitle", message: "DeleteTaskMessage", OKAction: {
                self.deleteTask(index: indexPath)
            })
        }
    }
    
    /**
     課題を削除
     - Parameters:
        - index: IndexPath
     */
    func deleteTask(index: IndexPath) {
        let task = taskArray[index.row]
        updateTaskIsDeleted(task: task)
        taskArray.remove(at: index.row)
        tableView.deleteRows(at: [index], with: UITableView.RowAnimation.left)
        selectedIndex = nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 右スワイプで未完了
        let completeAction = UIContextualAction(style: .normal, title: NSLocalizedString("InComplete", comment: ""),
                                               handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            self.completeTask(index: indexPath)
            completion(true)
        })
        completeAction.backgroundColor = UIColor.systemBlue
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    /**
     課題を未完了にする
     - Parameters:
        - index: IndexPath
     */
    func completeTask(index: IndexPath) {
        let task = taskArray[index.row]
        updateTaskIsCompleted(task: task, isCompleted: false)
        taskArray.remove(at: index.row)
        tableView.deleteRows(at: [index], with: UITableView.RowAnimation.right)
        selectedIndex = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskArray.isEmpty {
            return 0
        } else {
            return taskArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.getTitle()
        cell.detailTextLabel?.text = "\(NSLocalizedString("Measures", comment: ""))：\(getMeasuresTitleInTask(ID: task.getTaskID()))"
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.accessibilityIdentifier = "TaskViewCell"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        delegate?.completedTaskVCTaskCellDidTap(task: taskArray[indexPath.row])
    }
}
