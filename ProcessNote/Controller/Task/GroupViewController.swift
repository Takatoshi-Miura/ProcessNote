//
//  GroupViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import UIKit


protocol GroupViewControllerDelegate: AnyObject {
    // グループ削除時の処理
    func groupVCDeleteGroup()
}


class GroupViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    private var sectionTitle: [String] = []
    private var groupArray: [Group] = [Group]()
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    var group = Group()
    var delegate: GroupViewControllerDelegate?

    private enum Section: Int {
        case title = 0
        case color
        case order
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initColorPicker()
        groupArray = getGroupArrayForTaskView()
    }
    
    func initNavigationBar() {
        self.title = TITLE_GROUP_DETAIL
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteGroup))
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    /// グループを削除
    @objc func deleteGroup() {
        showDeleteAlert(title: TITLE_DELETE_GROUP, message: MESSAGE_DELETE_GROUP, OKAction: {
            updateGroupIsDeleted(group: self.group)
            self.delegate?.groupVCDeleteGroup()
        })
    }
    
    func initTableView() {
        sectionTitle = [TITLE_TITLE, TITLE_COLOR, TITLE_GROUP_ORDER]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isEditing = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func initColorPicker() {
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: colorPicker.bounds.size.height + 44)
        colorPicker.backgroundColor = UIColor.systemGray5
        pickerIndex = group.getColor()
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateGroup(group: group)
        }
    }

}


extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        switch Section(rawValue: section) {
        case .title:
            return 1
        case .color:
            return 1
        case .order:
            if groupArray.isEmpty {
                return 0
            } else {
                return groupArray.count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Section.order.rawValue {
            return true // 表示順のみ並び替え許可
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 並び順を保存
        let group = groupArray[sourceIndexPath.row]
        groupArray.remove(at: sourceIndexPath.row)
        groupArray.insert(group, at: destinationIndexPath.row)
        updateGroupOrderRealm(groupArray: groupArray)
    }
    
    func tableView(_ tableView:UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.section != sourceIndexPath.section) {
            return sourceIndexPath  // セクションを超えた並び替え禁止
        }
        return proposedDestinationIndexPath;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.setTitle(group.getTitle())
            if !isiPad() {
                cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case .color:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            let colorNum = colorNumber[colorTitle[pickerIndex]]!
            cell.setColor(colorNum)
            cell.setTitle(Array(colorNumber.filter {$0.value == colorNum}.keys).first!)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case .order:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = groupArray[indexPath.row].getTitle()
            cell.backgroundColor = UIColor.systemGray6
            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.3))
            separatorView.backgroundColor = UIColor.gray
            cell.addSubview(separatorView)
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


extension GroupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == group.getTitle() {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: MESSAGE_EMPTY_TITLE)
            textField.text = group.getTitle()
            return false
        }
        
        // グループを更新
        updateGroupTitleRealm(ID: group.getGroupID(), title: textField.text!)
        return true
    }
    
}


extension GroupViewController: ColorCellDelegate {
    
    func tapColorButton(_ button: UIButton) {
        closePicker(pickerView)
        pickerView = UIView(frame: colorPicker.bounds)
        pickerView.addSubview(colorPicker)
        pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
        openPicker(pickerView)
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
        pickerIndex = colorPicker.selectedRow(inComponent: 0)
        closePicker(pickerView)
        updateGroupColorRealm(ID: group.getGroupID(), colorNumber: colorNumber[colorTitle[pickerIndex]]!)
        tableView.reloadRows(at: [[Section.color.rawValue, 0]], with: .none)
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}


extension GroupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorTitle.count  // カラーの項目数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorTitle[row]   // 文字列
    }
    
}
