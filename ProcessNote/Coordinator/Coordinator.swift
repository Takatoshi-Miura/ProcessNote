//
//  Coordinator.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/11/06.
//

import UIKit


protocol Coordinator: AnyObject {
    
    func startFlow(in window: UIWindow?)
    
    func startFlow(in navigationController: UINavigationController)
    
}
