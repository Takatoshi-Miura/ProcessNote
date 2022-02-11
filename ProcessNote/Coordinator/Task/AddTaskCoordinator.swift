//
//  AddTaskCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/02/11.
//

import UIKit

class AddTaskCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addTaskViewController = AddTaskViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addTaskViewController = AddTaskViewController()
        addTaskViewController.delegate = self
        if #available(iOS 13.0, *) {
            addTaskViewController.isModalInPresentation = true
        }
        previousViewController!.present(addTaskViewController, animated: true)
    }
    
}

extension AddTaskCoordinator: AddTaskViewControllerDelegate {
    
    // TaskVC ← AddTaskVC
    func AddTaskVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
