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
        self.title = TITLE_COMPLETED_TASK
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (tableView.indexPathForSelectedRow != nil) {
            // 課題が未完了or削除されていれば取り除く
            let task = taskArray[tableView.indexPathForSelectedRow!.row]
            if !task.getIsCompleted() || task.getIsDeleted() {
                taskArray.remove(at: tableView.indexPathForSelectedRow!.row)
                tableView.deleteRows(at: [tableView.indexPathForSelectedRow!], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .none)
        }
    }
}


extension CompletedTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(getMeasuresTitleInTask(ID: task.getTaskID()))"
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.accessibilityIdentifier = "TaskViewCell"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.completedTaskVCTaskCellDidTap(task: taskArray[indexPath.row])
    }
}
