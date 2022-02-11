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
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
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
        let cancelAction = UIAlertAction(title: TITLE_CANCEL, style: UIAlertAction.Style.default, handler: nil)
        showAlert(title: title, message: message, actions: [cancelAction, OKAction])
    }
    
    /**
     OKアラートを表示(アクション付き)
     - Parameters:
       - title: タイトル
       - message: 説明文
       - OKAction: OKをタップした時の処理
     */
    func showOKAlert(title: String, message: String, OKAction: @escaping () -> ()) {
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in OKAction()})
        showAlert(title: title, message: message, actions: [OKAction])
    }
    
    /**
     エラーアラートを表示
     - Parameters:
       - message: 説明文
     */
    func showErrorAlert(message: String) {
        showOKAlert(title: TITLE_ERROR, message: message)
    }
    
    /**
     削除アラートを表示
     - Parameters:
        - title: タイトル
        - message: 説明文
        - OKAction: OKをタップした時の処理
     */
    func showDeleteAlert(title: String, message: String, OKAction: @escaping () -> ()) {
        let OKAction = UIAlertAction(title: TITLE_DELETE,
                                     style: UIAlertAction.Style.destructive, handler: {(action: UIAlertAction) in OKAction()})
        let cancelAction = UIAlertAction(title: TITLE_CANCEL,
                                         style: UIAlertAction.Style.cancel, handler: nil)
        showAlert(title: title, message: message, actions: [OKAction, cancelAction])
    }
    
    /**
     アクションシートを表示
     - Parameters:
       - title: タイトル
       - message: 説明文
       - actions: [UIAlertAction]
       - frame: フレーム(iPadの場合のみ必要)
     */
    func showActionSheet(title: String, message: String, actions: [UIAlertAction], frame: CGRect?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.addAction(UIAlertAction(title: TITLE_CANCEL, style: .cancel, handler: nil))
        if isiPad() {
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = frame!
        }
        present(actionSheet, animated: true)
    }
}
