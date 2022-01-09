//
//  AddTaskViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import UIKit


class AddTaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    private var sectionTitle: [String] = []
    private var cellTitle: [[String]] = [[]]
    private var realmGroupArray: [Group] = []
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    
    private enum Section: Int {
        case title
        case cause
        case measures
        case group
        case addition
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initColorPicker()
        realmGroupArray = getGroupArrayForTaskView()
    }
    
    func initNavigationBar() {
        naviItem.title = TITLE_ADD_TASK
    }
    
    func initTableView() {
        sectionTitle = [TITLE_TITLE, TITLE_CAUSE, TITLE_MEASURES, TITLE_GROUP, ""]
        cellTitle = [[""], [""], [""], [""], [""]]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.register(UINib(nibName: "SaveButtonCell", bundle: nil), forCellReuseIdentifier: "SaveButtonCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func initColorPicker() {
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: colorPicker.bounds.size.height + 44)
        colorPicker.backgroundColor = UIColor.systemGray5
        pickerView = UIView(frame: colorPicker.bounds)
        pickerView.addSubview(colorPicker)
        pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
        pickerIndex = colorPicker.selectedRow(inComponent: 0)
        closePicker(pickerView)
        tableView.reloadData()
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
}


extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        return cellTitle[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.textField.placeholder = TITLE_TASK_EXAMPLE
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case .cause:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.textView.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case .measures:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.textField.placeholder = TITLE_MEASURE_EXAMPLE
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case .group:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            let colorNum = realmGroupArray[pickerIndex].getColor()
            cell.setColor(colorNum)
            cell.setTitle(realmGroupArray[pickerIndex].getTitle())
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
            return cell
        case .addition:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveButtonCell", for: indexPath) as! SaveButtonCell
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddTaskViewCell"
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


extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
}


extension AddTaskViewController: ColorCellDelegate {
    
    func tapColorButton(_ button: UIButton) {
        openPicker(pickerView)
    }
    
}


extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realmGroupArray.count  // グループ数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return realmGroupArray[row].getTitle()   // グループ名
    }
    
}


extension AddTaskViewController: SaveButtonCellDelegate {
    
    func tapSaveButton() {
        // 入力チェック
        let titleCell = tableView.cellForRow(at: [0, 0]) as! TitleCell
        if titleCell.textField.text!.isEmpty {
            showErrorAlert(message: MESSAGE_EMPTY_TITLE)
            return
        }
        let causeTextCell = tableView.cellForRow(at: [1, 0]) as! TextViewCell
        let measuresCell = tableView.cellForRow(at: [2, 0]) as! TitleCell
        
        // 課題データを作成＆保存
        let task = Task()
        task.setFixedProperty()
        task.setGroupID(realmGroupArray[pickerIndex].getGroupID())
        task.setTitle(titleCell.textField.text!)
        task.setCause(causeTextCell.textView.text!)
        task.setOrder(getTasksInGroup(ID: task.getGroupID(), isCompleted: false).count)
        task.setUpdated_at(task.getCreated_at())
        if !createRealm(object: task) {
            showErrorAlert(message: MESSAGE_TASK_CREATE_ERROR)
            return
        }
        
        // 対策データを作成＆保存
        let measures = Measures()
        measures.setFixedProperty()
        measures.setTaskID(task.getTaskID())
        measures.setTitle(measuresCell.textField.text!)
        measures.setOrder(0)
        measures.setUpdated_at(measures.getCreated_at())
        if !measuresCell.textField.text!.isEmpty {
            if !createRealm(object: measures) {
                showErrorAlert(message: MESSAGE_TASK_CREATE_ERROR)
                return
            }
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            saveTask(task: task, completion: {})
            if !measuresCell.textField.text!.isEmpty {
                saveMeasures(measures: measures, completion: {})
            }
        }
        self.dismissWithInsertTask(task: task)
    }
    
    /**
     課題画面に課題を追加してモーダルを閉じる
     */
    func dismissWithInsertTask(task: Task) {
        let tabBar = self.presentingViewController as! UITabBarController
        let navigation = tabBar.selectedViewController as! UINavigationController
        let taskView = navigation.viewControllers.first as! TaskViewController
        taskView.insertTask(task: task)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
