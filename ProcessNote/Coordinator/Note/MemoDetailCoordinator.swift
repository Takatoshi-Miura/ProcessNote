//
//  MemoCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/10.
//

import UIKit


class MemoDetailCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var memoDetailViewController = MemoDetailViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in navigationController: UINavigationController, withMemo memo: Memo) {
        self.navigationController = navigationController
        memoDetailViewController = MemoDetailViewController()
        memoDetailViewController.delegate = self
        memoDetailViewController.memo = memo
        navigationController.pushViewController(memoDetailViewController, animated: true)
    }
    
}


extension MemoDetailCoordinator: MemoDetailViewControllerDelegate {
    
    // NoteDetailVC ← MemoDetailVC
    func memoDetailVCDeleteMemo() {
        navigationController?.popViewController(animated: true)
    }
    
}
