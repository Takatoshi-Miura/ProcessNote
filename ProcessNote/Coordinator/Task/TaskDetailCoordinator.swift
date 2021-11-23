//
//  TaskDetailCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/06.
//

import UIKit


class TaskDetailCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var taskDetailViewController = TaskDetailViewController()
    let measuresCoordinator = MeasuresCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withTask task: Task) {
        self.navigationController = navigationController
        taskDetailViewController = TaskDetailViewController()
        taskDetailViewController.delegate = self
        taskDetailViewController.task = task
        navigationController.pushViewController(taskDetailViewController, animated: true)
    }
    
}


extension TaskDetailCoordinator: TaskDetailViewControllerDelegate {
    
    // TaskVC ← TaskDetailVC
    func taskDetailVCCompleteTask(task: Task) {
        navigationController?.popToRootViewController(animated: true)
        let taskVC = navigationController?.topViewController as! TaskViewController
        if !task.getIsCompleted() {
            taskVC.insertTask(task: task)
        }
    }
    
    // TaskVC ← TaskDetailVC
    // CompleteTaskVC ← TaskDetailVC
    func taskDetailVCDeleteTask(task: Task) {
        navigationController?.popViewController(animated: true)
    }
    
    // TaskDetailVC → MeasuresVC
    func taskDetailVCMeasuresCellDidTap(measures: Measures) {
        measuresCoordinator.startFrow(in: navigationController!, withMeasures: measures)
    }
    
}

