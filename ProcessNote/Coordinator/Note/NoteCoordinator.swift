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
    let addNoteCoordinator = AddNoteCoordinator()
    let memoDetailCoordinator = MemoDetailCoordinator()
    let noteFilterCoordinator = NoteFilterCoordinator()
    
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
        addNoteCoordinator.startFlow(in: viewController)
    }
    
    // NoteVC → NoteDetailVC
    func noteVCMemoDidTap(memo: Memo) {
        memoDetailCoordinator.startFlow(in: navigationController!, withMemo: memo)
    }
    
    // NoteVC → NoteFilterVC
    func noteVCFilterDidTap(_ viewController: NoteViewController) {
        noteFilterCoordinator.startFlow(in: viewController)
    }
    
}

