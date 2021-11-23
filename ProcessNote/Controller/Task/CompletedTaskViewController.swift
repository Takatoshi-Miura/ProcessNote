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
            // 課題が未完了or削除されていれば取り除く
            let task = taskArray[selectedIndex!.row]
            if !task.getIsCompleted() || task.getIsDeleted() {
                taskArray.remove(at: selectedIndex!.row)
                tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
                selectedIndex = nil
                return
            }
            tableView.reloadRows(at: [selectedIndex!], with: .none)
            selectedIndex = nil
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
