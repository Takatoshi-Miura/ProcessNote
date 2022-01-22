//
//  UIViewController+PickerView.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import UIKit

public extension UIViewController {
    
    /**
     PickerViewを画面下から出現
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
     */
    func openPicker(_ pickerView:UIView) {
        view.addSubview(pickerView)
        pickerView.frame.origin.y = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.3) {
            pickerView.frame.origin.y = UIScreen.main.bounds.size.height - pickerView.bounds.size.height
        }
    }
    
    /**
     PickerViewを画面下から出現(スクロール有)
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
        - scrollPosition: 現在のスクロール位置
        - bottomPadding: SafeArea外の余白
     */
    func openPicker(_ pickerView:UIView, _ scrollPosition:CGFloat, _ bottomPadding:CGFloat) {
        pickerView.frame.origin.y = scrollPosition
        UIView.animate(withDuration: 0.3) {
            pickerView.frame.origin.y = scrollPosition - pickerView.bounds.size.height - bottomPadding
        }
    }
    
    /**
     PickerViewを閉じる
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
     */
    func closePicker(_ pickerView:UIView) {
        UIView.animate(withDuration: 0.3) {
            pickerView.frame.origin.y += pickerView.bounds.size.height
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            pickerView.removeFromSuperview()
        }
    }
    
    /**
     ツールバーを作成(キャンセル、完了ボタン)
     - Parameters:
        - doneAction: 完了ボタンの処理
        - cancelAction: キャンセルボタンの処理
     - Returns: ツールバー
     */
    func createToolBar(_ doneAction:Selector, _ cancelAction:Selector) -> UIToolbar {
        // ツールバーを作成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        // ボタン作成＆セット
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        // 作成したツールバーを返却
        return toolbar
    }

}
