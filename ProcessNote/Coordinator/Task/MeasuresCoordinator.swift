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
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withMeasures measures: Measures) {
        self.navigationController = navigationController
        measuresViewController = MeasuresViewController()
        measuresViewController.measures = measures
        navigationController.pushViewController(measuresViewController, animated: true)
    }
    
}
