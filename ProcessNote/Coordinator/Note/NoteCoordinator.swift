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
    let settingCoordinator = SettingCoordinator()
    
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
    
    // NoteVC → SettingVC
    func noteVCHumburgerMenuButtonDidTap(_ viewController: NoteViewController) {
        settingCoordinator.startFlow(in: viewController)
    }
    
}

