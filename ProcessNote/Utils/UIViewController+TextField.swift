//
//  UIViewController+TextField.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import UIKit

public extension UIViewController {
    
    /**
     ツールバーを作成(完了ボタン)
     - Parameters:
        - doneAction: 完了ボタンの処理
     - Returns: ツールバー
     */
    func createToolBar(_ doneAction:Selector) -> UIToolbar {
        // ツールバーを作成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        // ボタン作成＆セット
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleItem,doneItem], animated: true)
        // 作成したツールバーを返却
        return toolbar
    }
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
