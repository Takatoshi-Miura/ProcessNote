//
//  NotePageCoordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/06.
//

import UIKit


class NotePageCoordinator: NSObject, Coordinator {
    
    var navigationController: UINavigationController?
    var notePageViewController = NotePageViewController()
    let noteDetailCoordinator = NoteDetailCoordinator()
    private var controllers: [UINavigationController] = []
    private var noteArray = getNoteArrayForNoteView()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        notePageViewController = NotePageViewController()
        for note in noteArray {
            let navController = UINavigationController()
            navController.setNavigationBarHidden(false, animated: false)
            noteDetailCoordinator.startFlow(in: navController, withNote: note)
            self.controllers.append(navController)
        }
        notePageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        notePageViewController.dataSource = self
        navigationController.pushViewController(notePageViewController, animated: true)
    }
}


extension NotePageCoordinator: UIPageViewControllerDataSource {
    
    /// 現在のインデックスを取得
    func indexOfController(viewController:UIViewController) -> Int{
        for i in 0 ..< controllers.count {
            if (viewController == controllers[i]) {
                return i
            }
        }
        return NSNotFound
    }

    /// ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.controllers.count
    }
   
    /// 左にスワイプ（進む）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfController(viewController:viewController)
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (0 <= index && index < controllers.count) {
            return controllers[index]
        }
        return nil
    }

    /// 右にスワイプ （戻る）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfController(viewController:viewController)
        if (index == NSNotFound) {
            return nil
        }
        index -= 1
        if (0 <= index && index < controllers.count) {
            return controllers[index]
        }
        return nil
    }

}

