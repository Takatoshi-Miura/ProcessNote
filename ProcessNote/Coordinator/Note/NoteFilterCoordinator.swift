//
//  NoteFilterCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/01/22.
//

import UIKit

class NoteFilterCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var noteFilterViewController = NoteFilterViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        noteFilterViewController = NoteFilterViewController()
        noteFilterViewController.delegate = self
        if #available(iOS 13.0, *) {
            noteFilterViewController.isModalInPresentation = true
        }
        if isiPad() {
            noteFilterViewController.modalPresentationStyle = .fullScreen
        }
        previousViewController!.present(noteFilterViewController, animated: true)
    }
    
}

extension NoteFilterCoordinator: NoteFilterViewControllerDelegate {
    
    // NoteVC ← NoteFilterVC
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
