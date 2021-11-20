//
//  SettingViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController {
    
    // MARK: UI,Variable
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath = [0, 0]
    var sectionTitle: [String] = []
    var cellTitle: [[String]] = [[]]
    
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
    }
    
    /**
     NavigationControllerの初期設定
     */
    func initNavigationController() {
        self.title = NSLocalizedString("Setting", comment: "")
    }
    
    /**
     tableViewの初期設定
     */
    func initTableView() {
        sectionTitle = [NSLocalizedString("Basic configuration", comment: ""),
                        NSLocalizedString("Data", comment: ""),
                        NSLocalizedString("Help", comment: "")]
        cellTitle = [[NSLocalizedString("Theme", comment: ""),
                      NSLocalizedString("Notification", comment: "")],
                     [NSLocalizedString("Data transfer", comment: "")],
                     [NSLocalizedString("How to use this App?", comment: ""),
                      NSLocalizedString("Inquiry", comment: "")]]
        tableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
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
        cell.setText(cellTitle[indexPath.section][indexPath.row])
        cell.setIconImage(UIImage(systemName: "questionmark.circle")!)
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "SettingViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        
        switch cellTitle[indexPath.section][indexPath.row] {
        case NSLocalizedString("Theme", comment: ""):
            // TODO: テーマ設定
            break
        case NSLocalizedString("Notification", comment: ""):
            // TODO: 通知設定
            break
        case NSLocalizedString("Data transfer", comment: ""):
            // TODO: データの引継ぎ
            if !Network.isOnline() {
                showErrorAlert(message: "Internet Error")
            }
            break
        case NSLocalizedString("How to use this App?", comment: ""):
            // TODO: チュートリアル
            break
        case NSLocalizedString("Inquiry", comment: ""):
            self.startMailer()
            break
        default:
            break
        }
        
        // タップしたときの選択色を消去
        tableView.deselectRow(at: selectedIndex as IndexPath, animated: true)
    }
}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    /**
     メーラーを起動
     */
    func startMailer() {
        if MFMailComposeViewController.canSendMail() == false {
            showErrorAlert(message: "Mailer Error")
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients(["ProcessNote開発者<it6210ge@gmail.com>"])
        mailViewController.setSubject(NSLocalizedString("Mail Subject", comment: ""))
        mailViewController.setMessageBody(NSLocalizedString("Mail Message", comment: ""), isHTML: false)
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    /**
     メーラーを終了
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            showOKAlert(title: "Success", message: "Mail Send Success")
            break
        case .failed:
            showErrorAlert(message: "Mail Send Failed")
            break
        default:
            break
        }
    }
}
