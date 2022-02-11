//
//  AddGroupCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/02/11.
//

import UIKit

class AddGroupCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addGroupViewController = AddGroupViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addGroupViewController = AddGroupViewController()
        addGroupViewController.delegate = self
        if #available(iOS 13.0, *) {
            addGroupViewController.isModalInPresentation = true
        }
        previousViewController!.present(addGroupViewController, animated: true)
    }
    
}

extension AddGroupCoordinator: AddGroupViewControllerDelegate {
    
    // TaskVC ← AddGroupVC
    func addGroupVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

