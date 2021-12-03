//
//  TaskViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol TaskViewControllerDelegate: AnyObject {
    // ハンバーガーメニューボタンタップ時の処理
    func taskVCHumburgerMenuButtonDidTap(_ viewController: UIViewController)
    // セクションヘッダータップ時の処理
    func taskVCHeaderDidTap(group: Group)
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
    @IBOutlet weak var addButton: UIButton!
    var selectedIndex: IndexPath?
    var realmGroupArray: [Group] = [Group]()
    var realmTaskArray: [[Task]] = [[Task]]()
    var delegate: TaskViewControllerDelegate?
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        addRightSwipeGesture()
        syncData()
    }
    
    func initNavigationController() {
        self.title = NSLocalizedString("Task", comment: "")
        
        var menuButton: UIBarButtonItem
        if UITraitCollection.current.userInterfaceStyle == .dark {
            menuButton = UIBarButtonItem(image: UIImage(named: "humburger_menu_white")!.withRenderingMode(.alwaysOriginal),
                                         style: .plain,
                                         target: self,
                                         action: #selector(openHumburgerMenu(_:)))
        } else {
            menuButton = UIBarButtonItem(image: UIImage(named: "humburger_menu_black")!.withRenderingMode(.alwaysOriginal),
                                         style: .plain,
                                         target: self,
                                         action: #selector(openHumburgerMenu(_:)))
        }
         
        navigationItem.leftBarButtonItems = [menuButton]
    }
    
    /// ハンバーガーメニューを表示
    @objc func openHumburgerMenu(_ sender: UIBarButtonItem) {
        self.delegate?.taskVCHumburgerMenuButtonDidTap(self)
    }
    
    /// 課題・グループを追加
    @IBAction func addButtonTap(_ sender: Any) {
        // アクションシートを表示
        let addGroupAction = UIAlertAction(title: NSLocalizedString("Group", comment: ""), style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        if !realmGroupArray.isEmpty {
            let addTaskAction = UIAlertAction(title: NSLocalizedString("Task", comment: ""), style: .default) { _ in
                self.delegate?.taskVCAddTaskDidTap(self)
            }
            showActionSheet(title: "AddGroupTaskTitle", message: "AddGroupTaskMessage", actions: [addGroupAction, addTaskAction])
        } else {
            showActionSheet(title: "AddGroupTaskTitle", message: "AddGroupTaskMessage", actions: [addGroupAction])
        }
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: String(describing: GroupHeaderView.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: String(describing: GroupHeaderView.self))
        tableView.isEditing = true  // セルの常時並び替え許可
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 右スワイプでハンバーガーメニューを閉じる
    func addRightSwipeGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(openHumburgerMenu(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    /// データの同期処理
    @objc func syncData() {
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
            // 未完了の課題から戻る場合
            if selectedIndex!.row < realmTaskArray[selectedIndex!.section].count {
                // 課題が完了or削除されていれば取り除く
                let task = realmTaskArray[selectedIndex!.section][selectedIndex!.row]
                if task.getIsCompleted() || task.getIsDeleted() {
                    realmTaskArray[selectedIndex!.section].remove(at: selectedIndex!.row)
                    tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
                    selectedIndex = nil
                    return
                }
            }
            tableView.reloadRows(at: [selectedIndex!], with: .none)
            selectedIndex = nil
        } else {
            // グループから戻る場合はリロード
            realmGroupArray = getGroupArrayForTaskView()
            realmTaskArray = getTaskArrayForTaskView()
            tableView.reloadData()
        }
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
            headerView.delegate = self
            headerView.setProperty(group: realmGroupArray[section])
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
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
        let task = realmTaskArray[selectedIndex!.section][selectedIndex!.row]
        delegate?.taskVCTaskCellDidTap(task: task)
    }
}


extension TaskViewController: GroupHeaderViewDelegate {
    
    // セクションヘッダータップ時の処理
    func headerDidTap(view: GroupHeaderView) {
        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
}
