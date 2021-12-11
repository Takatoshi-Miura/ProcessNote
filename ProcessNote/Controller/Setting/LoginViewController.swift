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
        case mailAddress
        case password
        case loginButton
        case newUser
        case cancel
    }

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        sectionTitle = [NSLocalizedString("MailAddress", comment: ""),
                        NSLocalizedString("Password", comment: ""),
                        "", "", ""]
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Section(rawValue: section) == .loginButton {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .mailAddress:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.textField.delegate = self
            cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case .loginButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == 0 {
                cell.setTitle(NSLocalizedString("Login", comment: ""))
            } else if indexPath.row == 1 {
                cell.setTitle(NSLocalizedString("Forgot password", comment: ""))
            }
            return cell
        case .newUser:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
            cell.setTitle(NSLocalizedString("Create account", comment: ""))
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
            cell.setTitle(NSLocalizedString("Cancel", comment: ""))
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
    
    func tapColorButton() {
        self.delegate?.LoginVCCancelDidTap(self)
    }
    
}
