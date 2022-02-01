//
//  AddGroupViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/10.
//

import UIKit


class AddGroupViewController: UIViewController {

    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    private var sectionTitle: [String] = []
    private var cellTitle: [[String]] = [[]]
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    
    private enum Section: Int {
        case title
        case color
        case addition
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initColorPicker()
    }
    
    func initNavigationBar() {
        naviItem.title = TITLE_ADD_GROUP
    }
    
    func initTableView() {
        sectionTitle = [TITLE_TITLE, TITLE_COLOR, ""]
        cellTitle = [[""], [""], [""]]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.register(UINib(nibName: "SaveButtonCell", bundle: nil), forCellReuseIdentifier: "SaveButtonCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func initColorPicker() {
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: colorPicker.bounds.size.height + 44)
        colorPicker.backgroundColor = UIColor.systemGray5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    @IBAction func hundleRightSwipeGesture(_ sender: Any) {
        dismissWithInputCheck()
    }
    
    /// 入力済みの場合、確認アラートを表示
    private func dismissWithInputCheck() {
        let cell = tableView.cellForRow(at: [0, 0]) as! TitleCell
        if !cell.textField.text!.isEmpty {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.dismiss(animated: true, completion: nil)
            })
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension AddGroupViewController: UITableViewDelegate, UITableViewDataSource {

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
            if !isiPad() {
                cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            }
            cell.textField.placeholder = TITLE_GROUP_EXAMPLE
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddGroupViewCell"
            return cell
        case .color:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            let colorNum = colorNumber[colorTitle[pickerIndex]]!
            cell.setColor(colorNum)
            cell.setTitle(Array(colorNumber.filter {$0.value == colorNum}.keys).first!)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddGroupViewCell"
            return cell
        case .addition:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SaveButtonCell", for: indexPath) as! SaveButtonCell
            cell.delegate = self
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "AddGroupViewCell"
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
    
    
extension AddGroupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension AddGroupViewController: ColorCellDelegate {
    
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
        tableView.reloadData()
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}
 

extension AddGroupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
 

extension AddGroupViewController: SaveButtonCellDelegate {
    
    func tapSaveButton() {
        // 入力チェック
        let cell = tableView.cellForRow(at: [0, 0]) as! TitleCell
        if cell.textField.text!.isEmpty {
            showErrorAlert(message: MESSAGE_EMPTY_TITLE)
            return
        }
        
        // グループデータを作成＆保存
        let group = Group()
        group.setFixedProperty()
        group.setColor(colorNumber[colorTitle[pickerIndex]]!)
        group.setTitle(cell.textField.text!)
        group.setOrder(getGroupArrayForTaskView().count)
        print(group.getOrder())
        group.setUpdated_at(group.getCreated_at())
        if !createRealm(object: group) {
            showErrorAlert(message: MESSAGE_GROUP_CREATE_ERROR)
            return
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            saveGroup(group: group, completion: {
                self.dismissWithReload(group: group)
            })
        } else {
            self.dismissWithReload(group: group)
        }
    }
    
    /**
     課題画面をリロードしてモーダルを閉じる
     */
    func dismissWithReload(group: Group) {
        let tabBar = self.presentingViewController as! UITabBarController
        let navigation = tabBar.selectedViewController as! UINavigationController
        let taskView = navigation.viewControllers.first as! TaskViewController
        taskView.insertGroup(group: group)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tapCancelButton() {
        dismissWithInputCheck()
    }
}
