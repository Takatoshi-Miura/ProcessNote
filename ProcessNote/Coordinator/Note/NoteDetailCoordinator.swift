//
//  NoteDetailCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/05.
//

import UIKit


class NoteDetailCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var noteDetailViewController = NoteDetailViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in navigationController: UINavigationController, withNote note: Note) {
        self.navigationController = navigationController
        noteDetailViewController = NoteDetailViewController()
        noteDetailViewController.delegate = self
        noteDetailViewController.note = note
        navigationController.pushViewController(noteDetailViewController, animated: true)
    }
}

extension NoteDetailCoordinator: NoteDetailViewControllerDelegate {
    
    // NoteVC ← NoteDetailVC
    func noteDetailVCDeleteNote() {
        navigationController?.popViewController(animated: true)
    }
    
}
