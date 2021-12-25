//
//  MeasuresCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/21.
//

import UIKit


class MeasuresCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var measuresViewController = MeasuresViewController()
    let memoDetailCoordinator = MemoDetailCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withMeasures measures: Measures) {
        self.navigationController = navigationController
        measuresViewController = MeasuresViewController()
        measuresViewController.delegate = self
        measuresViewController.measures = measures
        navigationController.pushViewController(measuresViewController, animated: true)
    }
    
}


extension MeasuresCoordinator: MeasuresViewControllerDelegate {
    
    // TaskDetailVC ← MeasuresVC
    func measuresVCDeleteMeasures() {
        navigationController?.popViewController(animated: true)
    }
    
    // MeasuresVC → MemoDetailVC
    func measuresVCMemoDidTap(memo: Memo) {
        memoDetailCoordinator.startFlow(in: navigationController!, withMemo: memo)
    }
    
}
