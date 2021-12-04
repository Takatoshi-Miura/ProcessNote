//
//  AddNoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import UIKit


class AddNoteViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var sectionTitle: [String] = []
    var groupArray: [Group] = []
    var taskArray: [Task] = []
    var pickerView = UIView()
    let colorPicker = UIPickerView()
    var pickerIndex: Int = 0
    var viewOffset: CGPoint?
    
    enum Section: Int {
        case group = 0
        case task
        case save
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initColorPicker()
        groupArray = getGroupArrayForTaskView()
        taskArray = getTasksInGroup(ID: groupArray[pickerIndex].getGroupID(), isCompleted: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initNavigationBar() {
        naviItem.title = NSLocalizedString("AddNoteTitle", comment: "")
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("Group", comment: ""), NSLocalizedString("Task", comment: ""), ""]
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.register(UINib(nibName: "NoteTextViewCell", bundle: nil), forCellReuseIdentifier: "NoteTextViewCell")
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
        taskArray = getTasksInGroup(ID: groupArray[pickerIndex].getGroupID(), isCompleted: false)
        tableView.reloadData()
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        viewOffset = tableView.contentOffset
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            if let unwrappedOffset = self.viewOffset {
                self.tableView.contentOffset = unwrappedOffset
            }
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
}


extension AddNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        if section == 1 {
            if taskArray.isEmpty {
                return 0
            } else {
                return taskArray.count
            }
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .group:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            let colorNum = groupArray[pickerIndex].getColor()
            cell.setColor(colorNum)
            cell.setTitle(groupArray[pickerIndex].getTitle())
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddNoteViewCell"
            return cell
        case .task:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTextViewCell", for: indexPath) as! NoteTextViewCell
            cell.memo.delegate = self
            cell.setLabelText(taskArray[indexPath.row])
            cell.memo.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddNoteViewCell"
            return cell
        case .save:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveButtonCell", for: indexPath) as! SaveButtonCell
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddNoteViewCell"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.task.rawValue {
            return 158
        } else {
            return 44
        }
    }
    
}


extension AddNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
}


extension AddNoteViewController: ColorCellDelegate {
    
    func tapColorButton() {
        openPicker(pickerView)
    }
    
}


extension AddNoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groupArray.count  // グループ数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groupArray[row].getTitle()   // グループ名
    }
    
}


extension AddNoteViewController: SaveButtonCellDelegate {
    
    func tapSaveButton() {
        // 入力チェック
        
        // 課題データを作成＆保存
        
    }
    
    func tapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

