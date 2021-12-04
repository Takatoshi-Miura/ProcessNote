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
    let completedTaskCoordinator = CompletedTaskCoordinator()
    let groupCoordinator = GroupCoordinator()
    let settingCoordinator = SettingCoordinator()
    
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
    
    // TaskVC → SettingVC
    func taskVCHumburgerMenuButtonDidTap(_ viewController: UIViewController) {
        settingCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → GroupVC
    func taskVCHeaderDidTap(group: Group) {
        groupCoordinator.startFrow(in: navigationController!, withGroup: group)
    }
    
    // TaskVC → TaskDetailVC
    func taskVCTaskCellDidTap(task: Task) {
        taskDetailCoordinator.startFrow(in: navigationController!, withTask: task)
    }
    
    // TaskVC → AddGroupVC
    func taskVCAddGroupDidTap(_ viewController: UIViewController) {
        addGroupViewController = AddGroupViewController()
        if #available(iOS 13.0, *) {
            addGroupViewController.isModalInPresentation = true
        }
        viewController.present(addGroupViewController, animated: true)
    }
    
    // TaskVC → AddTaskVC
    func taskVCAddTaskDidTap(_ viewController: UIViewController) {
        addTaskViewController = AddTaskViewController()
        if #available(iOS 13.0, *) {
            addTaskViewController.isModalInPresentation = true
        }
        viewController.present(addTaskViewController, animated: true)
    }
    
    // TaskVC → completedTaskVC
    func taskVCCompletedTaskCellDidTap(groupID: String) {
        completedTaskCoordinator.startFrow(in: navigationController!, withGroupID: groupID)
    }
    
}

