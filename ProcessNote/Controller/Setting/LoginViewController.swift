//
//  LoginViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/11.
//

import UIKit
import Firebase
import SVProgressHUD


protocol LoginViewControllerDelegate: AnyObject {
    // キャンセルをタップ時の処理
    func LoginVCCancelDidTap(_ viewController: UIViewController)
    // ログイン、ログアウト、パスワードリセット時の処理
    func LoginVCUserDidLogin(_ viewController: UIViewController)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if let _ = UserDefaults.standard.object(forKey: "address") as? String,
               let _ = UserDefaults.standard.object(forKey: "password") as? String
            {
                return NSLocalizedString("AlreadyLogin", comment: "")
            }
        }
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .login:
            if indexPath.row == 0 || indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
                cell.textField.delegate = self
                cell.textField.inputAccessoryView = createToolBar(#selector(completeAction))
                cell.textField.keyboardType = .emailAddress
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                if indexPath.row == 0 {
                    cell.textField.placeholder = NSLocalizedString("MailAddress", comment: "")
                    cell.textField.tag = TextFieldTag.mail.rawValue
                    if let address = UserDefaults.standard.object(forKey: "address") as? String {
                        cell.textField.text = address
                    }
                } else {
                    cell.textField.placeholder = NSLocalizedString("Password", comment: "")
                    cell.textField.isSecureTextEntry = true
                    cell.textField.tag = TextFieldTag.password.rawValue
                    if let password = UserDefaults.standard.object(forKey: "password") as? String {
                        cell.textField.text = password
                    }
                }
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if indexPath.row == 2 {
                // ログイン状態によってログイン、ログアウト分岐
                if let _ = UserDefaults.standard.object(forKey: "address") as? String,
                   let _ = UserDefaults.standard.object(forKey: "password") as? String
                {
                    cell.setTitle(NSLocalizedString("Logout", comment: ""))
                    cell.setColor(colorNumber[NSLocalizedString("Red", comment: "")]!)
                } else {
                    cell.setTitle(NSLocalizedString("Login", comment: ""))
                }
                cell.colorButton.tag = ButtonTag.login.rawValue
            } else if indexPath.row == 3 {
                cell.setTitle(NSLocalizedString("Forgot password", comment: ""))
                cell.colorButton.tag = ButtonTag.forgotPassword.rawValue
            } else {
                cell.setColor(colorNumber[NSLocalizedString("Blue", comment: "")]!)
                cell.setTitle(NSLocalizedString("Create account", comment: ""))
                cell.colorButton.tag = ButtonTag.createAccount.rawValue
            }
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
            cell.delegate = self
            cell.colorButton.backgroundColor = UIColor.systemGray
            cell.setTitle(NSLocalizedString("Cancel", comment: ""))
            cell.colorButton.tag = ButtonTag.cancel.rawValue
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
        let mailText = mailCell.textField.text!
        let passwordText = passwordCell.textField.text!
        
        switch ButtonTag(rawValue: button.tag) {
        case .login:
            if let address = mailCell.textField.text, let password = passwordCell.textField.text {
                if address.isEmpty || password.isEmpty {
                    showErrorAlert(message: "EmptyTextError")
                    return
                }
                // ログイン状態によってログイン、ログアウト分岐
                if let _ = UserDefaults.standard.object(forKey: "address") as? String,
                   let _ = UserDefaults.standard.object(forKey: "password") as? String
                {
                    logout()
                } else {
                    login(mail: address, password: password)
                }
            }
        case .forgotPassword:
            if mailText.isEmpty {
                showErrorAlert(message: "EmptyTextErrorPasswordReset")
                return
            }
            showOKCancelAlert(title: "PasswordResetTitle", message: "PasswordResetMessage", OKAction: {
                self.sendPasswordResetMail(mail: mailText)
            })
        case .createAccount:
            if mailText.isEmpty || passwordText.isEmpty {
                showErrorAlert(message: "EmptyTextError")
                return
            }
            showOKCancelAlert(title: "CreateAccountTitle", message: "CreateAccountMessage", OKAction: {
                self.createAccount(mail: mailText, password: passwordText)
            })
        case .cancel:
            self.delegate?.LoginVCCancelDidTap(self)
        default:
            break
        }
    }
    
    /**
     ログイン処理
     - Parameters:
        - mail: メールアドレス
        - password: パスワード
     */
    func login(mail address: String, password pass: String) {
        SVProgressHUD.show(withStatus: NSLocalizedString("DuringLoginProcess", comment: ""))
        
        Auth.auth().signIn(withEmail: address, password: pass) { authResult, error in
            // エラー処理
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .invalidEmail:
                        SVProgressHUD.showError(withStatus: NSLocalizedString("InvalidEmail", comment: ""))
                    case .wrongPassword:
                        SVProgressHUD.showError(withStatus: NSLocalizedString("WrongPassword", comment: ""))
                    default:
                        SVProgressHUD.showError(withStatus: NSLocalizedString("LoginError", comment: ""))
                    }
                    return
                }
            }
            
            // UserDefaultsにユーザー情報を保存
            UserDefaultsKey.userID.set(value: Auth.auth().currentUser!.uid)
            UserDefaultsKey.address.set(value: address)
            UserDefaultsKey.password.set(value: pass)
            
            // メッセージが隠れてしまうため、遅延処理を行ってから画面遷移
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("LoginSuccessful", comment: ""))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.LoginVCUserDidLogin(self)
            }
        }
    }
    
    /// ログアウト処理
    func logout() {
        do {
            try Auth.auth().signOut()
            
            // UserDefaultsのユーザー情報を削除
            UserDefaultsKey.userID.remove()
            UserDefaultsKey.address.remove()
            UserDefaultsKey.password.remove()
            
            // Realmデータを全削除
            deleteAllTaskRealm()
            deleteAllGroupRealm()
            deleteAllMeasuresRealm()
            deleteAllNoteRealm()
            deleteAllMemoRealm()
            
            // テキストフィールドをクリア
            let mailCell = tableView.cellForRow(at: [0, 0]) as! TitleCell
            let passwordCell = tableView.cellForRow(at: [0, 1]) as! TitleCell
            mailCell.textField.text = ""
            passwordCell.textField.text = ""
            
            // ユーザーIDを作成(初期値を登録)
            UserDefaultsKey.userID.set(value: NSUUID().uuidString)
            
            // メッセージが隠れてしまうため、遅延処理を行う
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("LogoutSuccessful", comment: ""))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.LoginVCUserDidLogin(self)
            }
        } catch _ as NSError {
            SVProgressHUD.dismiss()
            showErrorAlert(message: NSLocalizedString("LogoutError", comment: ""))
        }
    }
    
    /**
     パスワードリセットメールを送信
     - Parameters:
        - mail: メールアドレス
     */
    func sendPasswordResetMail(mail address: String) {
        Auth.auth().sendPasswordReset(withEmail: address) { (error) in
            if error != nil {
                self.showErrorAlert(message: "MailSendError")
                return
            }
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("MailSendSuccessful", comment: ""))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.LoginVCUserDidLogin(self)
            }
        }
    }
    
    /**
     アカウント作成処理
     - Parameters:
        - mail: メールアドレス
        - password: パスワード
     */
    func createAccount(mail address: String, password pass: String) {
        showIndicator(message: "DuringCreateAccountProcess")
        
        // アカウント作成処理
        Auth.auth().createUser(withEmail: address, password: pass) { authResult, error in
            if error != nil {
                self.dismissIndicator()
                // エラーのハンドリング
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: NSLocalizedString("InvalidEmail", comment: ""))
                        case .emailAlreadyInUse:
                            SVProgressHUD.showError(withStatus: NSLocalizedString("EmailAlreadyInUse", comment: ""))
                        case .weakPassword:
                            SVProgressHUD.showError(withStatus: NSLocalizedString("WeakPassword", comment: ""))
                        default:
                            SVProgressHUD.showError(withStatus: NSLocalizedString("CreateAccountError", comment: ""))
                    }
                    return
                }
            }
            
            // FirebaseのユーザーIDとログイン情報を保存
            UserDefaultsKey.userID.set(value: Auth.auth().currentUser!.uid)
            UserDefaultsKey.address.set(value: address)
            UserDefaultsKey.password.set(value: pass)
            
            // RealmデータのuserIDを新しいIDに更新
            updateGroupUserID(userID: Auth.auth().currentUser!.uid)
            updateTaskUserID(userID: Auth.auth().currentUser!.uid)
            updateMeasuresUserID(userID: Auth.auth().currentUser!.uid)
            updateNoteUserID(userID: Auth.auth().currentUser!.uid)
            updateMemoUserID(userID: Auth.auth().currentUser!.uid)
            
            // Firebaseと同期
            syncDatabase(completion: {
                self.dismissIndicator()
                self.delegate?.LoginVCUserDidLogin(self)
                SVProgressHUD.showSuccess(withStatus: NSLocalizedString("DataTransferSuccessful", comment: ""))
            })
        }
    }
    
}
