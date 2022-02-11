//
//  TaskViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import GoogleMobileAds
import PKHUD


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
    @IBOutlet weak var adView: UIView!
    private var groupArray: [Group] = [Group]()
    private var taskArray: [[Task]] = [[Task]]()
    private var adMobView: GADBannerView?
    var delegate: TaskViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotificasion()
        initNavigationController()
        initTableView()
        addRightSwipeGesture()
        syncData()
        displayAgreement()
    }
    
    func setNotificasion() {
        // ログイン、ログアウト時のリロード用
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncData), name: NSNotification.Name(rawValue: "dataUpdated"), object: nil)
    }
        
    func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initNavigationController() {
        self.title = TITLE_TASK
        
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let image = isDarkMode ? UIImage(named: "humburger_menu_white")! : UIImage(named: "humburger_menu_black")!
        let menuButton = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                                         style: .plain,
                                         target: self,
                                         action: #selector(openHumburgerMenu(_:)))
        navigationItem.leftBarButtonItems = [menuButton]
    }
    
    /// ハンバーガーメニューを表示
    @objc func openHumburgerMenu(_ sender: UIBarButtonItem) {
        self.delegate?.taskVCHumburgerMenuButtonDidTap(self)
    }
    
    /// 課題・グループを追加
    @IBAction func addButtonTap(_ sender: Any) {
        let addGroupAction = UIAlertAction(title: TITLE_GROUP, style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addTaskAction = UIAlertAction(title: TITLE_TASK, style: .default) { _ in
            self.delegate?.taskVCAddTaskDidTap(self)
        }
        
        var alertActions: [UIAlertAction] = []
        alertActions.append(addGroupAction)
        if !groupArray.isEmpty {
            alertActions.append(addTaskAction)
        }
        
        showActionSheet(title: TITLE_ADD_GROUP_TASK, message: MESSAGE_ADD_GROUP_TASK, actions: alertActions, frame: addButton.frame)
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: String(describing: GroupHeaderView.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: String(describing: GroupHeaderView.self))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 右スワイプでハンバーガーメニューを開く
    func addRightSwipeGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(openHumburgerMenu(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            syncDatabase(completion: {
                self.refreshData()
                HUD.hide()
            })
        } else {
            refreshData()
        }
    }
    
    /// データを再取得
    func refreshData() {
        groupArray = getGroupArrayForTaskView()
        taskArray = getTaskArrayForTaskView()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func displayAgreement() {
        // 初回起動判定
        if UserDefaultsKey.firstLaunch.bool() {
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            UserDefaultsKey.firstLaunch.set(value: false)
            
            // 利用規約を表示
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
            })
        }
        
        // 同意していないなら利用規約を表示
        if !UserDefaultsKey.agree.bool() {
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
            })
        }
    }
    
    /// 利用規約アラートを表示
    func displayAgreement(_ completion: @escaping () -> ()) {
        // 同意ボタン
        let agreeAction = UIAlertAction(title: TITLE_AGREEMENT, style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            HUD.hide()
            completion()
        }
        // 利用規約ボタン
        let termsAction = UIAlertAction(title: TITLE_READ_TERMS, style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            // 規約画面に遷移
            let url = URL(string: "https://sportnote-b2c92.firebaseapp.com/")
            UIApplication.shared.open(url!)
            // アラートが消えるため再度表示
            self.displayAgreement({
                completion()
            })
        }
        showAlert(title: TITLE_AGREE, message: MESSAGE_AGREE, actions: [termsAction, agreeAction])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    /// バナー広告を表示
    func showAdMob() {
        if let adMobView = adMobView {
            adMobView.frame.size = CGSize(width: self.view.frame.width, height: adMobView.frame.height)
            return
        }
        adMobView = GADBannerView()
        adMobView = GADBannerView(adSize: GADAdSizeBanner)
        adMobView!.adUnitID = "ca-app-pub-9630417275930781/9800556170"
        adMobView!.rootViewController = self
        adMobView!.load(GADRequest())
        adMobView!.frame.origin = CGPoint(x: 0, y: 0)
        adMobView!.frame.size = CGSize(width: self.view.frame.width, height: adMobView!.frame.height)
        self.adView.addSubview(adMobView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 課題が完了or削除されていれば取り除く
            if selectedIndex.row < taskArray[selectedIndex.section].count {
                let task = taskArray[selectedIndex.section][selectedIndex.row]
                if task.getIsCompleted() || task.getIsDeleted() {
                    taskArray[selectedIndex.section].remove(at: selectedIndex.row)
                    tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                    return
                }
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        } else {
            // グループから戻る場合はリロード
            refreshData()
        }
    }
    
    /**
     グループを挿入
     - Parameters:
        - group: 挿入するグループ
     */
    func insertGroup(group: Group) {
        let index: IndexPath = [group.getOrder(), 0]
        groupArray.append(group)
        taskArray.append([])
        tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
    }
    
    /**
     課題を挿入(最後尾に追加)
     - Parameters:
        - task: 挿入する課題
     */
    func insertTask(task: Task) {
        var index: IndexPath = [0, 0]
        for group in groupArray {
            if task.getGroupID() == group.getGroupID() {
                // グループに含まれる課題数を並び順にセットする
                let tasks = getTasksInGroup(ID: group.getGroupID(), isCompleted: false)
                updateTaskOrderRealm(task: task, order: tasks.count - 1)
                // tableViewに課題を追加
                index = [index.section, tasks.count - 1]
                taskArray[index.section].append(task)
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
            headerView.setProperty(group: groupArray[section])
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
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= taskArray[indexPath.section].count {
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
        if indexPath.row >= taskArray[indexPath.section].count {
            return false    // 完了課題セルは並び替え不可
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 完了課題セルの下に入れようとした場合は課題の最下端に並び替え
        var destinationIndex = destinationIndexPath
        let count = taskArray[destinationIndex.section].count
        if destinationIndex.row >= count {
            destinationIndex.row = count == 0 ? 0 : count - 1
        }
        
        // 並び順を保存
        let task = taskArray[sourceIndexPath.section][sourceIndexPath.row]
        taskArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        taskArray[destinationIndex.section].insert(task, at: destinationIndex.row)
        updateTaskOrderRealm(taskArray: taskArray)
        
        // グループが変わる場合はグループも更新
        if sourceIndexPath.section != destinationIndex.section {
            let groupId = groupArray[destinationIndex.section].getGroupID()
            updateTaskGroupIdRealm(task: task, ID: groupId)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.row >= taskArray[indexPath.section].count {
            // 完了済み課題セル
            cell.textLabel?.text = TITLE_COMPLETED_TASK
            cell.textLabel?.textColor = UIColor.systemBlue
        } else {
            // 課題セル
            let task = taskArray[indexPath.section][indexPath.row]
            cell.textLabel?.text = task.getTitle()
            cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(getMeasuresTitleInTask(ID: task.getTaskID()))"
            cell.detailTextLabel?.textColor = UIColor.lightGray
            cell.accessibilityIdentifier = "TaskViewCell"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 完了済み課題セル
        if indexPath.row >= taskArray[indexPath.section].count {
            let groupID = groupArray[indexPath.section].getGroupID()
            delegate?.taskVCCompletedTaskCellDidTap(groupID: groupID)
            return
        }
        // 課題セル
        let task = taskArray[indexPath.section][indexPath.row]
        delegate?.taskVCTaskCellDidTap(task: task)
    }
}


extension TaskViewController: GroupHeaderViewDelegate {
    
    // セクションヘッダータップ時の処理
    func headerDidTap(view: GroupHeaderView) {
        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
    // セクションヘッダーのinfoボタンタップ時の処理
    func infoButtonDidTap(view: GroupHeaderView) {
        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
}
