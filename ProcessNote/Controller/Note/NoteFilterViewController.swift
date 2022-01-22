//
//  NoteFilterViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/01/22.
//

import UIKit


protocol NoteFilterViewControllerDelegate: AnyObject {
    // キャンセルボタンタップ時の処理
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController)
    // 適用ボタンタップ時の処理
    func noteFilterVCApplyDidTap(_ viewController: NoteFilterViewController)
}


class NoteFilterViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    var delegate: NoteFilterViewControllerDelegate?
    
    private var groupArray: [Group] = []
    private var taskArray: [Task] = []
    private var pickerView = UIView()
    private let groupPicker = UIPickerView()
    private let taskPicker = UIPickerView()
    private var groupPickerSelected: Int = 0
    private var taskPickerSelected: Int = 0
    
    private enum Tag: Int {
        case group = 0
        case task
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = TITLE_PERIOD
        initNavigationBar()
        initPickerView()
        initGroupTaskData()
        loadFilterData()
    }
    
    func initNavigationBar() {
        naviItem.title = TITLE_FILTER_NOTE
        clearButton.title = TITLE_CLEAR
    }
    
    func initPickerView() {
        groupPicker.delegate = self
        groupPicker.dataSource = self
        groupPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: groupPicker.bounds.size.height + 44)
        groupPicker.backgroundColor = UIColor.systemGray5
        groupPicker.tag = Tag.group.rawValue
        
        taskPicker.delegate = self
        taskPicker.dataSource = self
        taskPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: taskPicker.bounds.size.height + 44)
        taskPicker.backgroundColor = UIColor.systemGray5
        taskPicker.tag = Tag.task.rawValue
    }
    
    func initGroupTaskData() {
        // 0番目に「すべて表示」用ダミーデータを追加
        let dummyGroup = Group()
        groupArray = getGroupArrayForTaskView()
        groupArray.insert(dummyGroup, at: 0)
        
        let dummyTask = Task()
        taskArray = getTasksInGroup(ID: groupArray[groupPickerSelected].getGroupID())
        taskArray.insert(dummyTask, at: 0)
    }
    
    func loadFilterData() {
        // グループフィルタの読み込み
        if let filterGroupID = UserDefaultsKey.filterGroupID.object() as? String {
            let group = getGroup(ID: filterGroupID)
            groupPickerSelected = groupArray.firstIndex(of: group)!
            groupPicker.selectRow(groupPickerSelected, inComponent: 0, animated: false)
            initGroupTaskData()
        }
        // 課題フィルタの読み込み
        if let filterTaskID = UserDefaultsKey.filterTaskID.object() as? String {
            let task = getTask(taskID: filterTaskID)
            taskPickerSelected = taskArray.firstIndex(of: task)!
            taskPicker.selectRow(taskPickerSelected, inComponent: 0, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        groupPicker.frame.size.width = self.view.bounds.size.width
        taskPicker.frame.size.width = self.view.bounds.size.width
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate?.noteFilterVCCancelDidTap(self)
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
        // 検索フィルタをクリア
        UserDefaultsKey.filterGroupID.remove()
        UserDefaultsKey.filterTaskID.remove()
        groupPickerSelected = 0
        taskPickerSelected = 0
        groupPicker.selectRow(groupPickerSelected, inComponent: 0, animated: false)
        taskPicker.selectRow(taskPickerSelected, inComponent: 0, animated: false)
        initGroupTaskData()
        tableView.reloadData()
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        // グループフィルタを保存
        if groupPickerSelected == 0 {
            UserDefaultsKey.filterGroupID.remove()
        } else {
            let filterGroupID = groupArray[groupPickerSelected].getGroupID()
            UserDefaultsKey.filterGroupID.set(value: filterGroupID)
        }
        // 課題フィルタを保存
        if taskPickerSelected == 0 {
            UserDefaultsKey.filterTaskID.remove()
        } else {
            let filterTaskID = taskArray[taskPickerSelected].getTaskID()
            UserDefaultsKey.filterTaskID.set(value: filterTaskID)
        }
        delegate?.noteFilterVCApplyDidTap(self)
    }
    
}


extension NoteFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2    // グループ,課題
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        switch Tag(rawValue: indexPath.row) {
        case .group:
            cell.textLabel?.text = TITLE_GROUP
            if groupPickerSelected == 0 {
                cell.detailTextLabel?.text = TITLE_SHOW_ALL
            } else {
                cell.detailTextLabel?.text = groupArray[groupPickerSelected].getTitle()
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .task:
            cell.textLabel?.text = TITLE_TASK
            if taskPickerSelected == 0 {
                cell.detailTextLabel?.text = TITLE_SHOW_ALL
            } else {
                cell.detailTextLabel?.text = taskArray[taskPickerSelected].getTitle()
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        closePicker(pickerView)
        initGroupTaskData()
        switch Tag(rawValue: indexPath.row) {
        case .group:
            pickerView = UIView(frame: groupPicker.bounds)
            pickerView.tag = Tag.group.rawValue
            pickerView.addSubview(groupPicker)
        case .task:
            pickerView = UIView(frame: taskPicker.bounds)
            pickerView.tag = Tag.task.rawValue
            pickerView.addSubview(taskPicker)
        default:
            break
        }
        pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
        openPicker(pickerView)
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            groupPickerSelected = groupPicker.selectedRow(inComponent: 0)
            taskPickerSelected = 0
            taskPicker.selectRow(taskPickerSelected, inComponent: 0, animated: false)
            initGroupTaskData()
        case .task:
            taskPickerSelected = taskPicker.selectedRow(inComponent: 0)
        default:
            break
        }
        closePicker(pickerView)
        tableView.reloadData()
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            groupPicker.selectRow(groupPickerSelected, inComponent: 0, animated: false)
        case .task:
            taskPicker.selectRow(taskPickerSelected, inComponent: 0, animated: false)
        default:
            break
        }
        closePicker(pickerView)
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .none)
    }
    
}


extension NoteFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            return groupArray.count
        case .task:
            return taskArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return TITLE_SHOW_ALL
        }
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            return groupArray[row].getTitle()
        case .task:
            return taskArray[row].getTitle()
        default:
            return ""
        }
    }
    
}
