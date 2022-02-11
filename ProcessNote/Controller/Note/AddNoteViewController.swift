//
//  AddNoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import UIKit


protocol AddNoteViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addNoteVCDismiss(_ viewController: UIViewController)
}


class AddNoteViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    
    private var groupArray: [Group] = []
    private var taskArray: [Task] = []
    private var measuresArray: [Measures] = []
    
    private var pickerView = UIView()
    private let groupPicker = UIPickerView()
    private let taskPicker = UIPickerView()
    private let measuresPicker = UIPickerView()
    private var groupPickerSelected: Int = 0
    private var taskPickerSelected: Int = 0
    private var measuresPickerSelected: Int = 0
    private var viewOffset: CGPoint?
    var delegate: AddNoteViewControllerDelegate?
    
    private enum Tag: Int {
        case group = 0
        case task
        case measures
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initPickerView()
        initTextView()
        groupArray = getGroupArrayForTaskView()
        taskArray = getTasksInGroup(ID: groupArray[0].getGroupID(), isCompleted: false)
        measuresArray = getMeasuresInTask(ID: taskArray[0].getTaskID())
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initNavigationBar() {
        naviItem.title = TITLE_ADD_NOTE
    }
    
    func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
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
        
        measuresPicker.delegate = self
        measuresPicker.dataSource = self
        measuresPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: measuresPicker.bounds.size.height + 44)
        measuresPicker.backgroundColor = UIColor.systemGray5
        measuresPicker.tag = Tag.measures.rawValue
    }
    
    func initTextView() {
        textView.text = ""
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.sizeToFit()
        if !isiPad() {
            textView.inputAccessoryView = createToolBar(#selector(completeAction))
        }
    }
    
    // キーボードを閉じる
    @objc func completeAction() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        viewOffset = textView.contentOffset
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            if let unwrappedOffset = self.viewOffset {
                self.tableView.contentOffset = unwrappedOffset
            }
            self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        groupPicker.frame.size.width = self.view.bounds.size.width
        taskPicker.frame.size.width = self.view.bounds.size.width
        measuresPicker.frame.size.width = self.view.bounds.size.width
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // キーボード自動起動
        textView.becomeFirstResponder()
    }
    
    @IBAction func saveButtonDIdTap(_ sender: Any) {
        // 何も入力していなければアラート
        if textView.text.isEmpty {
            showOKAlert(title: TITLE_ERROR, message: MESSAGE_EMPTY_NOTE, OKAction: {
                self.textView.becomeFirstResponder()
            })
            return
        }
        
        // メモ作成＆保存
        let memo = Memo()
        let measure = measuresArray[measuresPickerSelected]
        memo.setMeasuresID(measure.getMeasuresID())
        memo.setDetail(textView.text)
        memo.setUpdated_at(getCurrentTime())
        if !createRealm(object: memo) {
            showErrorAlert(message: MESSAGE_NOTE_CREATE_ERROR)
            return
        }
        if Network.isOnline() {
            saveMemo(memo: memo, completion: {})
        }
        
        dismissWithInsertMemo(memo: memo)
    }
    
    /// ノート画面にノートを追加してモーダルを閉じる
    func dismissWithInsertMemo(memo: Memo) {
        let tabBar = self.presentingViewController as! UITabBarController
        let navigation = tabBar.selectedViewController as! UINavigationController
        let noteView = navigation.viewControllers.first as! NoteViewController
        noteView.insertMemo(memo: memo)
        self.delegate?.addNoteVCDismiss(self)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismissWithInputCheck()
    }
    
    @IBAction func hundleRightSwipeGesture(_ sender: Any) {
        dismissWithInputCheck()
    }
    
    /// 入力済みの場合、確認アラートを表示
    private func dismissWithInputCheck() {
        if !textView.text.isEmpty {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addNoteVCDismiss(self)
            })
            return
        }
        self.delegate?.addNoteVCDismiss(self)
    }
    
}


extension AddNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3    // グループ,課題,対策
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        switch Tag(rawValue: indexPath.row) {
        case .group:
            cell.textLabel?.text = TITLE_GROUP
            cell.detailTextLabel?.text = groupArray[groupPickerSelected].getTitle()
            cell.accessoryType = .disclosureIndicator
            return cell
        case .task:
            cell.textLabel?.text = TITLE_TASK
            cell.detailTextLabel?.text = taskArray[taskPickerSelected].getTitle()
            cell.accessoryType = .disclosureIndicator
            return cell
        case .measures:
            cell.textLabel?.text = TITLE_MEASURES
            cell.detailTextLabel?.text = measuresArray[measuresPickerSelected].getTitle()
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        closePicker(pickerView)
        switch Tag(rawValue: indexPath.row) {
        case .group:
            groupArray = getGroupArrayForTaskView()
            pickerView = UIView(frame: groupPicker.bounds)
            pickerView.tag = Tag.group.rawValue
            pickerView.addSubview(groupPicker)
        case .task:
            let group = groupArray[groupPickerSelected]
            taskArray = getTasksInGroup(ID: group.getGroupID(), isCompleted: false)
            pickerView = UIView(frame: taskPicker.bounds)
            pickerView.tag = Tag.task.rawValue
            pickerView.addSubview(taskPicker)
        case .measures:
            let task = taskArray[taskPickerSelected]
            measuresArray = getMeasuresInTask(ID: task.getTaskID())
            pickerView = UIView(frame: measuresPicker.bounds)
            pickerView.tag = Tag.measures.rawValue
            pickerView.addSubview(measuresPicker)
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
            measuresPickerSelected = 0
            taskPicker.selectRow(taskPickerSelected, inComponent: 0, animated: false)
            measuresPicker.selectRow(measuresPickerSelected, inComponent: 0, animated: false)
            taskArray = getTasksInGroup(ID: groupArray[groupPickerSelected].getGroupID(), isCompleted: false)
            measuresArray = getMeasuresInTask(ID: taskArray[0].getTaskID())
        case .task:
            taskPickerSelected = taskPicker.selectedRow(inComponent: 0)
            measuresPickerSelected = 0
            measuresPicker.selectRow(measuresPickerSelected, inComponent: 0, animated: false)
            measuresArray = getMeasuresInTask(ID: taskArray[taskPickerSelected].getTaskID())
        case .measures:
            measuresPickerSelected = measuresPicker.selectedRow(inComponent: 0)
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
        case .measures:
            measuresPicker.selectRow(measuresPickerSelected, inComponent: 0, animated: false)
        default:
            break
        }
        closePicker(pickerView)
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: .none)
    }
    
}


extension AddNoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        closePicker(pickerView)
        if let index = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [index], with: .none)
        }
    }
    
}


extension AddNoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            return groupArray.count
        case .task:
            return taskArray.count
        case .measures:
            return measuresArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch Tag(rawValue: pickerView.tag) {
        case .group:
            return groupArray[row].getTitle()
        case .task:
            return taskArray[row].getTitle()
        case .measures:
            return measuresArray[row].getTitle()
        default:
            return ""
        }
    }
    
}

