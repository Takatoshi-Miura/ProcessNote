//
//  UIViewController+Alert.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/09.
//

import UIKit

public extension UIViewController {
    
    /**
     アラートを表示
     - Parameters:
       - title: タイトル
       - message: 説明文
       - actions: [okAction、cancelAction]等
     */
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""),
                                      message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    /**
     OKアラートを表示
     - Parameters:
       - title: タイトル
       - message: 説明文
     */
    func showOKAlert(title: String, message: String) {
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        showAlert(title: title, message: message, actions: [OKAction])
    }
    
    /**
     OK,Cancelアラートを表示
     - Parameters:
       - title: タイトル
       - message: 説明文
       - OKAction: OKをタップした時の処理
     */
    func showOKCancelAlert(title: String, message: String, OKAction: @escaping () -> ()) {
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in OKAction()})
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        showAlert(title: title, message: message, actions: [cancelAction, OKAction])
    }
    
    /**
     エラーアラートを表示
     - Parameters:
       - message: 説明文
     */
    func showErrorAlert(message: String) {
        showOKAlert(title: "Error", message: message)
    }
    
    /**
     削除アラートを表示
     - Parameters:
        - title: タイトル
        - message: 説明文
        - OKAction: OKをタップした時の処理
     */
    func showDeleteAlert(title: String, message: String, OKAction: @escaping () -> ()) {
        let OKAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""),
                                     style: UIAlertAction.Style.destructive, handler: {(action: UIAlertAction) in OKAction()})
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: UIAlertAction.Style.cancel, handler: nil)
        showAlert(title: title, message: message, actions: [OKAction, cancelAction])
    }
    
    /**
     アクションシートを表示
     - Parameters:
       - title: タイトル
       - message: 説明文
       - actions: [UIAlertAction]
     */
    func showActionSheet(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""),
                                      message: NSLocalizedString(message, comment: ""), preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
