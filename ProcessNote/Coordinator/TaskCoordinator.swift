//
//  TaskCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/06.
//

import UIKit


class TaskCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var taskViewController = TaskViewController()
    var addGroupViewController = AddGroupViewController()
    var addTaskViewController = AddTaskViewController()
    let taskDetailCoordinator = TaskDetailCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        taskViewController = TaskViewController()
        taskViewController.delegate = self
        navigationController.pushViewController(taskViewController, animated: true)
    }
}


extension TaskCoordinator: TaskViewControllerDelegate {
    
    func taskVCTaskCellDidTap(task: Task) {
        taskDetailCoordinator.startFrow(in: navigationController!, withTask: task)
    }
    
    func taskVCAddGroupDidTap(_ viewController: UIViewController) {
        addGroupViewController = AddGroupViewController()
        viewController.present(addGroupViewController, animated: true)
    }
    
    func taskVCAddTaskDidTap(_ viewController: UIViewController) {
        addTaskViewController = AddTaskViewController()
        viewController.present(addTaskViewController, animated: true)
    }
    
}

