//
//  AddNoteCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/02/11.
//

import UIKit


class AddNoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addNoteViewController = AddNoteViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addNoteViewController = AddNoteViewController()
        addNoteViewController.delegate = self
        if #available(iOS 13.0, *) {
            addNoteViewController.isModalInPresentation = true
        }
        previousViewController!.present(addNoteViewController, animated: true)
    }
    
}


extension AddNoteCoordinator: AddNoteViewControllerDelegate {
    
    // NoteVC ← AddNoteVC
    func addNoteVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
