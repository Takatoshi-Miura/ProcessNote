//
//  AppDelegate.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import Firebase
import RealmSwift
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase用
        FirebaseApp.configure()
        
        // Google AdMob初期化
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Realmファイルの場所
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // 初回起動判定(初期値を登録)
        UserDefaults.standard.register(defaults: ["firstLaunch": true])
        
        // ユーザーIDを作成(初期値を登録)
        if (UserDefaults.standard.object(forKey: "userID") as? String == nil) {
            let uuid = NSUUID().uuidString
            UserDefaults.standard.set(uuid, forKey: "userID")
        }
        
        // アカウント持ちならFirebaseのユーザーIDを使用
        if let address = UserDefaults.standard.object(forKey: "address") as? String, let password = UserDefaults.standard.object(forKey: "password") as? String {
            // ログイン処理
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                // エラー処理
                if error != nil {
                    if AuthErrorCode(rawValue: error!._code) != nil {
                        return
                    }
                }
                // ログイン成功ならFirebaseのユーザーIDをuserIDとして使用
                UserDefaults.standard.set(Auth.auth().currentUser!.uid, forKey: "userID")
            }
        }
        
        // 初期画面を表示
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator()
        appCoordinator?.startFlow(in: window)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

