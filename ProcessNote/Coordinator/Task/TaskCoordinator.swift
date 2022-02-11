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
    let addGroupCoordinator = AddGroupCoordinator()
    let addTaskViewCoordinator = AddTaskCoordinator()
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
        addGroupCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → AddTaskVC
    func taskVCAddTaskDidTap(_ viewController: UIViewController) {
        addTaskViewCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → completedTaskVC
    func taskVCCompletedTaskCellDidTap(groupID: String) {
        completedTaskCoordinator.startFrow(in: navigationController!, withGroupID: groupID)
    }
    
}

