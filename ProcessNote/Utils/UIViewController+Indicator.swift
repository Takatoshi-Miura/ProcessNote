//
//  UIViewController+Indicator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import UIKit
import SVProgressHUD

public extension UIViewController {
    
    /**
     インジケータを表示
     - Parameters:
        - message: メッセージ
     */
    func showIndicator(message: String) {
        // 背景
        let backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        backgroundView.tag = 999
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        vc?.view.addSubview(backgroundView)
        
        // ローディング表示
        SVProgressHUD.show(withStatus: message)
    }
    
    /**
     インジケータを非表示
     */
    func dismissIndicator() {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        vc?.view.subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
        SVProgressHUD.dismiss()
    }

}
