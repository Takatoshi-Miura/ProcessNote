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
    var realmGroupArray: [Group] = []
    var pickerView = UIView()
    let colorPicker = UIPickerView()
    var pickerIndex: Int = 0
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initColorPicker()
        realmGroupArray = getGroupArrayForTaskView()
    }
    
    func initNavigationBar() {
        naviItem.title = NSLocalizedString("AddNoteTitle", comment: "")
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("Group", comment: "")]
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "TextViewCell")
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.delegate = self
        let colorNum = realmGroupArray[pickerIndex].getColor()
        cell.setColor(colorNum)
        cell.setTitle(realmGroupArray[pickerIndex].getTitle())
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.accessibilityIdentifier = "AddNoteViewCell"
        return cell
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
        return realmGroupArray.count  // グループ数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return realmGroupArray[row].getTitle()   // グループ名
    }
    
}
