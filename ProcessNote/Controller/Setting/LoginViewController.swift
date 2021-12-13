//
//  LoginViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/11.
//

import UIKit


protocol LoginViewControllerDelegate: AnyObject {
    // キャンセルをタップ時の処理
    func LoginVCCancelDidTap(_ viewController: UIViewController)
}


class LoginViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var sectionTitle: [String] = []
    var delegate: LoginViewControllerDelegate?
    
    enum Section: Int {
        case login
        case cancel
    }
    
    enum TextFieldTag: Int {
        case mail
        case password
    }
    
    enum ButtonTag: Int {
        case login
        case forgotPassword
        case createAccount
        case cancel
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        sectionTitle = ["", ""]
        tableView.register(UINib(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(UINib(nibName: "ColorCell", bundle: nil), forCellReuseIdentifier: "ColorCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
}


extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .login {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .login:
            if indexPath.row == 0 || indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
                cell.textField.delegate = self
                cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                if indexPath.row == 0 {
                    cell.textField.placeholder = NSLocalizedString("MailAddress", comment: "")
                    cell.textField.tag = TextFieldTag.mail.hashValue
                } else {
                    cell.textField.placeholder = NSLocalizedString("Password", comment: "")
                    cell.textField.tag = TextFieldTag.password.hashValue
                }
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == 2 {
                cell.setTitle(NSLocalizedString("Login", comment: ""))
                cell.colorButton.tag = ButtonTag.login.hashValue
            } else if indexPath.row == 3 {
                cell.setTitle(NSLocalizedString("Forgot password", comment: ""))
                cell.colorButton.tag = ButtonTag.forgotPassword.hashValue
            } else {
                cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
                cell.setTitle(NSLocalizedString("Create account", comment: ""))
                cell.colorButton.tag = ButtonTag.createAccount.hashValue
            }
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.colorButton.backgroundColor = UIColor.systemGray
            cell.setTitle(NSLocalizedString("Cancel", comment: ""))
            cell.colorButton.tag = ButtonTag.cancel.hashValue
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
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


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension LoginViewController: ColorCellDelegate {
    
    func tapColorButton(_ button: UIButton) {
        let mailCell = tableView.cellForRow(at: [0, 0]) as! TitleCell
        let passwordCell = tableView.cellForRow(at: [0, 1]) as! TitleCell
        
        switch button.tag {
        case ButtonTag.login.hashValue:
            if mailCell.textField.text!.isEmpty || passwordCell.textField.text!.isEmpty {
                showErrorAlert(message: "EmptyTextError")
            }
            // TODO: ログイン処理
        case ButtonTag.forgotPassword.hashValue:
            if mailCell.textField.text!.isEmpty {
                showErrorAlert(message: "EmptyTextError")
            }
            // TODO: パスワードリセット処理
        case ButtonTag.createAccount.hashValue:
            if mailCell.textField.text!.isEmpty || passwordCell.textField.text!.isEmpty {
                showErrorAlert(message: "EmptyTextError")
            }
            // TODO: アカウント作成処理
        case ButtonTag.cancel.hashValue:
            self.delegate?.LoginVCCancelDidTap(self)
        default:
            break
        }
    }
    
}
