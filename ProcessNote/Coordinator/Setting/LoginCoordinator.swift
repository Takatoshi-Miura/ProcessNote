//
//  LoginCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/11.
//

import UIKit


class LoginCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var loginViewController = LoginViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in modalViewController: UIViewController) {
        loginViewController = LoginViewController()
        loginViewController.delegate = self
        if #available(iOS 13.0, *) {
            loginViewController.isModalInPresentation = true
        }
        modalViewController.present(loginViewController, animated: true)
    }
    
}


extension LoginCoordinator: LoginViewControllerDelegate {
    
    // SettingVC ← LoginVC
    func LoginVCCancelDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: true)
    }
    
}
