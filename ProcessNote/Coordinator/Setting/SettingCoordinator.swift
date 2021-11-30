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
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in modalViewController: UIViewController) {
        settingViewController = SettingViewController()
        settingViewController.delegate = self
        settingViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.present(settingViewController, animated: false)
    }
}


extension SettingCoordinator: SettingViewControllerDelegate {
    
    // SettingVC → TaskVC or NoteVC
    func settingVCOutsideMenuDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: false, completion: nil)
    }
    
}
