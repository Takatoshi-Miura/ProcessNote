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
    let noteDetailCoordinator = NoteDetailCoordinator()
    var addNoteViewController = AddNoteViewController()
    
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
    
    // NoteVC → AddNoteVC
    func noteVCAddButtonDidTap(_ viewController: NoteViewController) {
        addNoteViewController = AddNoteViewController()
        if #available(iOS 13.0, *) {
            addNoteViewController.isModalInPresentation = true
        }
        viewController.present(addNoteViewController, animated: true)
    }
    
    // NoteVC → NoteDetailVC
    func noteVCNoteDidTap(note: Note) {
        noteDetailCoordinator.startFlow(in: navigationController!, withNote: note)
    }
    
}

