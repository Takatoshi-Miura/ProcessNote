//
//  GroupCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import UIKit


class GroupCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var groupViewController = GroupViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withGroup group: Group) {
        self.navigationController = navigationController
        groupViewController = GroupViewController()
        groupViewController.delegate = self
        groupViewController.group = group
        navigationController.pushViewController(groupViewController, animated: true)
    }
    
}


extension GroupCoordinator: GroupViewControllerDelegate {
    
    // TaskVC ← GroupVC
    func groupVCDeleteGroup() {
        navigationController?.popViewController(animated: true)
    }
    
}
