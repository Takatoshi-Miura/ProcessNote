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
        self.navigationController = navigationController
        navigationController.pushViewController(settingViewController, animated: true)
    }
}

