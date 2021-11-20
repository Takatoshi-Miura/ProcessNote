//
//  TaskViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol TaskViewControllerDelegate: AnyObject {
    // 課題セルタップ時の処理
    func taskVCTaskCellDidTap(task: Task)
    // グループ追加タップ時の処理
    func taskVCAddGroupDidTap(_ viewController: UIViewController)
    // 課題追加タップ時の処理
    func taskVCAddTaskDidTap(_ viewController: UIViewController)
    // 完了した課題セルタップ時の処理
    func taskVCCompletedTaskCellDidTap(groupID: String)
}


class TaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath?
    var realmGroupArray: [Group] = [Group]()
    var realmTaskArray: [[Task]] = [[Task]]()
    var delegate: TaskViewControllerDelegate?
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        syncData()
    }
    
    func initNavigationController() {
        self.title = NSLocalizedString("Task", comment: "")
        setNavigationBarButtonDefault()
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.allowsMultipleSelectionDuringEditing = true   // セル複数選択可能
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
                self.realmGroupArray = getGroupArrayForTaskView()
                self.realmTaskArray = getTaskArrayForTaskView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            realmGroupArray = getGroupArrayForTaskView()
            realmTaskArray = getTaskArrayForTaskView()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (selectedIndex != nil) {
            tableView.deselectRow(at: selectedIndex! as IndexPath, animated: true)
            tableView.reloadRows(at: [selectedIndex!], with: .none)
        }
    }
    
    
    // MARK: - NavigationBarAction
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            setNavigationBarButtonIsEditing()
        } else {
            setNavigationBarButtonDefault()
        }
        tableView.isEditing = editing
        tableView.reloadData()
    }
    
    /**
     通常時のNavigationBar設定
     */
    func setNavigationBarButtonDefault() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask(_:)))
        setNavigationBarButton(left: [editButtonItem], right: [addButton])
    }
    
    /**
     編集時のNavigationBar設定
     */
    func setNavigationBarButtonIsEditing() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTasks(_:)))
        setNavigationBarButton(left: [editButtonItem], right: [deleteButton])
    }
    
    /**
     NavigationBarにボタンをセット
      - Parameters:
        - left: 左側に表示するUIBarButtonItem
        - right: 右側に表示するUIBarButtonItem
     */
    func setNavigationBarButton(left leftBarItems: [UIBarButtonItem], right rightBarItems: [UIBarButtonItem]) {
        navigationItem.leftBarButtonItems = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    /**
     課題を追加
     */
    @objc func addTask(_ sender: UIBarButtonItem) {
        // アクションシートを表示
        let addGroupAction = UIAlertAction(title: NSLocalizedString("Group", comment: ""), style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addTaskAction = UIAlertAction(title: NSLocalizedString("Task", comment: ""), style: .default) { _ in
            self.delegate?.taskVCAddTaskDidTap(self)
        }
        showActionSheet(title: "AddGroupTaskTitle", message: "AddGroupTaskMessage", actions: [addGroupAction, addTaskAction])
    }
    
    /**
     課題を複数削除
     */
    @objc func deleteTasks(_ sender: UIBarButtonItem) {
        showDeleteAlert(title: "DeleteTaskTitle", message: "DeleteTaskMessage", OKAction: {
            // 配列の要素削除でindexの矛盾を防ぐため、降順にソートしてから削除
            guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else { return }
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            for indexPath in sortedIndexPaths {
                self.deleteTask(index: indexPath)
            }
        })
    }
    
    /**
     課題を削除
     - Parameters:
        - index: IndexPath
     */
    func deleteTask(index: IndexPath) {
        let task = realmTaskArray[index.section][index.row]
        updateTaskIsDeleted(task: task)
        realmTaskArray[index.section].remove(at: index.row)
        tableView.deleteRows(at: [index], with: UITableView.RowAnimation.left)
        selectedIndex = nil
    }
    
    /**
     課題を完了にする
     - Parameters:
        - index: IndexPath
     */
    func completeTask(index: IndexPath) {
        let task = realmTaskArray[index.section][index.row]
        updateTaskIsCompleted(task: task, isCompleted: true)
        realmTaskArray[index.section].remove(at: index.row)
        tableView.deleteRows(at: [index], with: UITableView.RowAnimation.right)
        selectedIndex = nil
    }
    
    /**
     グループを削除
     */
    @objc func deleteGroup(sender: UIButton) {
        if !tableView.isEditing { return }
        showDeleteAlert(title: "DeleteGroupTitle", message: "DeleteGroupMessage", OKAction: {
            let group = self.realmGroupArray[sender.tag]
            updateGroupIsDeleted(group: group)
            self.realmGroupArray.remove(at: sender.tag)
            self.realmTaskArray.remove(at: sender.tag)
            self.tableView.deleteSections(IndexSet(integer: sender.tag), with: UITableView.RowAnimation.left)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setEditing(false, animated: false)
            }
            self.selectedIndex = nil
        })
    }
    
    /**
     グループを挿入
     - Parameters:
        - group: 挿入するグループ
     */
    func insertGroup(group: Group) {
        let index: IndexPath = [group.getOrder(), 0]
        realmGroupArray.append(group)
        realmTaskArray.append([])
        tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
    }
    
    /**
     課題を挿入
     - Parameters:
        - task: 挿入する課題
     */
    func insertTask(task: Task) {
        var index: IndexPath = [0, task.getOrder()]
        for group in realmGroupArray {
            if task.getGroupID() == group.getGroupID() {
                realmTaskArray[index.section].append(task)
                tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
            }
            index = [index.section + 1, task.getOrder()]
        }
    }
}


extension TaskViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            headerView.setProperty(group: realmGroupArray[section])
            if tableView.isEditing {
                // セクション削除ボタンの設定
                let button = UIButton(frame: CGRect(x: self.view.frame.maxX - 50, y: 0, width: 50, height: headerView.bounds.height))
                button.backgroundColor = UIColor.systemRed
                button.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
                button.tag = section
                button.addTarget(self, action: #selector(deleteGroup(sender:)), for: .touchUpInside)
                headerView.addSubview(button)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            return headerView.bounds.height
        }
        return tableView.sectionHeaderHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return realmGroupArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= realmTaskArray[indexPath.section].count {
            return false    // 解決済みの課題セルは編集不可
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true // 並び替え許可
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 並び順を保存
        let task = realmTaskArray[sourceIndexPath.section][sourceIndexPath.row]
        realmTaskArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        realmTaskArray[destinationIndexPath.section].insert(task, at: destinationIndexPath.row)
        updateTaskOrderRealm(taskArray: realmTaskArray)
        
        // グループが変わる場合はグループも更新
        if sourceIndexPath.section != destinationIndexPath.section {
            let groupId = realmGroupArray[destinationIndexPath.section].getGroupID()
            updateTaskGroupIdRealm(task: task, ID: groupId)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 左スワイプで課題を削除
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteAlert(title: "DeleteTaskTitle", message: "DeleteTaskMessage", OKAction: {
                self.deleteTask(index: indexPath)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 右スワイプで完了
        let completeAction = UIContextualAction(style: .normal, title: NSLocalizedString("Complete", comment: ""),
                                               handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            self.completeTask(index: indexPath)
            completion(true)
        })
        completeAction.backgroundColor = UIColor.systemBlue
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmTaskArray[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.row >= realmTaskArray[indexPath.section].count {
            // 完了済み課題セル
            cell.textLabel?.text = NSLocalizedString("CompletedTask", comment: "")
            cell.textLabel?.textColor = UIColor.systemBlue
        } else {
            // 課題セル
            let task = realmTaskArray[indexPath.section][indexPath.row]
            cell.textLabel?.text = task.getTitle()
            cell.detailTextLabel?.text = "\(NSLocalizedString("Measures", comment: ""))：\(getMeasuresTitleInTask(ID: task.getTaskID()))"
            cell.detailTextLabel?.textColor = UIColor.lightGray
            cell.accessibilityIdentifier = "TaskViewCell"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        // 完了済み課題セル
        if indexPath.row >= realmTaskArray[indexPath.section].count {
            let groupID = realmGroupArray[indexPath.section].getGroupID()
            delegate?.taskVCCompletedTaskCellDidTap(groupID: groupID)
            return
        }
        // 課題セル
        if !tableView.isEditing {
            let task = realmTaskArray[selectedIndex!.section][selectedIndex!.row]
            delegate?.taskVCTaskCellDidTap(task: task)
        }
    }
}
