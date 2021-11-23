//
//  MeasuresViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import UIKit


protocol MeasuresViewControllerDelegate: AnyObject {
    // 対策削除時の処理
    func measuresVCDeleteMeasures()
}


class MeasuresViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var measures = Measures()
    var selectedIndex: IndexPath?
    var sectionTitle: [String] = []
    var delegate: MeasuresViewControllerDelegate?
    enum Section: Int {
        case title = 0
        case note
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
    }
    
    func initNavigationBar() {
        self.title = NSLocalizedString("MeasuresTitle", comment: "")
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMeasures))
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    /// 対策を削除
    @objc func deleteMeasures() {
        showDeleteAlert(title: "DeleteMeasuresTitle", message: "DeleteMeasuresMessage", OKAction: {
            updateMeasuresIsDeleted(measures: self.measures)
            if Network.isOnline() {
                updateMeasures(self.measures)
            }
            self.delegate?.measuresVCDeleteMeasures()
        })
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("Title", comment: ""),
                        NSLocalizedString("Note", comment: "")]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            updateMeasures(measures)
        }
    }
    
}


extension MeasuresViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        case .note:
            // TODO: 対策が持つメモの個数を返却
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.setTitle(measures.getTitle())
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.accessibilityIdentifier = "MeasuresViewCell"
            let task = selectTaskRealm(ID: measures.getTaskID())
            if task.getIsCompleted() {
                cell.textField.isEnabled = false
            }
            return cell
        case .note:
            // TODO: メモの内容をセルに表示
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//            cell.textLabel?.text = measuresArray[indexPath.row].getTitle()
//            cell.backgroundColor = UIColor.systemGray6
//            let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.5))
//            separatorView.backgroundColor = UIColor.gray
//            cell.addSubview(separatorView)
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


extension MeasuresViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == measures.getTitle() {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: "EmptyTitle")
            textField.text = measures.getTitle()
            return false
        }
        
        // 対策を更新
        updateMeasuresTitleRealm(ID: measures.getMeasuresID(), title: textField.text!)
        return true
    }
}
