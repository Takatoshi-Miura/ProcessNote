//
//  SettingViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import MessageUI


protocol SettingViewControllerDelegate: AnyObject {
    // メニュー外をタップ時の処理
    func settingVCOutsideMenuDidTap(_ viewController: UIViewController)
    // 引継ぎをタップ時の処理
    func settingVCDataTransferDidTap(_ viewController: UIViewController)
}


class SettingViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    var sectionTitle: [String] = []
    var cellTitle: [[String]] = [[]]
    var delegate: SettingViewControllerDelegate?
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        sectionTitle = [TITLE_DATA, TITLE_HELP]
        cellTitle = [[TITLE_DATA_TRANSFER],
                     [TITLE_HOW_TO_USE_THIS_APP, TITLE_INQUIRY]]
        tableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openMenuAnimation()
    }
    
    /// メニュー表示アニメーション
    func openMenuAnimation() {
        let menuPos = self.tableView.layer.position
        self.tableView.layer.position.x = -self.tableView.frame.width
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.layer.position.x = menuPos.x
        },completion: { bool in})
    }
    
    /// メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.tableView.layer.position.x = -self.tableView.frame.width
                }, completion: { bool in
                    self.delegate?.settingVCOutsideMenuDidTap(self)
                })
            }
        }
    }
}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        let title = cellTitle[indexPath.section][indexPath.row]
        cell.setText(title)
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "SettingViewCell"
        
        switch title {
        case TITLE_THEME:
            // TODO: テーマ設定
            break
        case TITLE_NOTIFICATION:
            // TODO: 通知設定
            break
        case TITLE_DATA_TRANSFER:
            cell.setIconImage(UIImage(systemName: "icloud.and.arrow.up")!)
            break
        case TITLE_HOW_TO_USE_THIS_APP:
            cell.setIconImage(UIImage(systemName: "questionmark.circle")!)
            break
        case TITLE_INQUIRY:
            cell.setIconImage(UIImage(systemName: "envelope")!)
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cellTitle[indexPath.section][indexPath.row] {
        case TITLE_THEME:
            // TODO: テーマ設定
            break
        case TITLE_NOTIFICATION:
            // TODO: 通知設定
            break
        case TITLE_DATA_TRANSFER:
            if !Network.isOnline() {
                showErrorAlert(message: MESSAGE_INTERNET_ERROR)
            }
            delegate?.settingVCDataTransferDidTap(self)
            break
        case TITLE_HOW_TO_USE_THIS_APP:
            let url = URL(string: "https://youtu.be/KxLESzQHh0s")
            UIApplication.shared.open(url!)
            break
        case TITLE_INQUIRY:
            self.startMailer()
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    /// メーラーを起動
    func startMailer() {
        if MFMailComposeViewController.canSendMail() == false {
            showErrorAlert(message: MESSAGE_MAILER_ERROR)
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients(["ProcessNote開発者<it6210ge@gmail.com>"])
        mailViewController.setSubject(TITLE_MAIL_SUBJECT)
        mailViewController.setMessageBody(TITLE_MAIL_MESSAGE, isHTML: false)
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    /// メーラーを終了
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            showOKAlert(title: TITLE_SUCCESS, message: MESSAGE_MAIL_SEND_SUCCESS)
            break
        case .failed:
            showErrorAlert(message: MESSAGE_MAIL_SEND_FAILED)
            break
        default:
            break
        }
    }
}
