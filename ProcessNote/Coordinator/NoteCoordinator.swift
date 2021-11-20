//
//  NoteCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/11.
//

import UIKit


class NoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var noteViewController = NoteViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        noteViewController = NoteViewController()
        noteViewController.delegate = self
        navigationController.pushViewController(noteViewController, animated: true)
    }
}

extension NoteCoordinator: NoteViewControllerDelegate {
    func noteViewControllerDidTap(_ viewController: NoteViewController) {
        let taskVC = TaskViewController()
        navigationController?.pushViewController(taskVC, animated: true)
    }
}

