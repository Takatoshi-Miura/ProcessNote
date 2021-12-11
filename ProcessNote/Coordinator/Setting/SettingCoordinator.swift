//
//  SettingCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/11.
//

import UIKit


class SettingCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var settingViewController = SettingViewController()
    let loginCoordinator = LoginCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in modalViewController: UIViewController) {
        settingViewController = SettingViewController()
        settingViewController.delegate = self
        settingViewController.modalPresentationStyle = .overFullScreen
        if #available(iOS 13.0, *) {
            settingViewController.isModalInPresentation = true
        }
        modalViewController.present(settingViewController, animated: false)
    }
}


extension SettingCoordinator: SettingViewControllerDelegate {
    
    // SettingVC → TaskVC
    func settingVCOutsideMenuDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }
    
    // SettingVC → LoginVC
    func settingVCDataTransferDidTap(_ viewController: UIViewController) {
        loginCoordinator.startFlow(in: viewController)
    }
    
}
