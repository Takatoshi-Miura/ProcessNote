//
//  ProcessNoteUITests.swift
//  ProcessNoteUITests
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import XCTest

class ProcessNoteUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /**
     課題画面のUIテスト
     */
    func testTaskViewControllerUI() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["TabBarController_task_button"].tap()
        
        XCTContext.runActivity(named: "[課題]NavigationBarの文言を確認") { (activity) in
            let navigationBar = app.navigationBars["課題"]
            XCTAssertTrue(navigationBar.exists)
        }
    }
    
    /**
     ノート画面のUIテスト
     */
    func testNoteViewControllerUI() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["TabBarController_note_button"].tap()
        
        XCTContext.runActivity(named: "[ノート]NavigationBarの文言を確認") { (activity) in
            let navigationBar = app.navigationBars["ノート"]
            XCTAssertTrue(navigationBar.exists)
        }
    }
    
    /**
     設定画面のUIテスト
     */
    func testSettingViewControllerUI() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["TabBarController_setting_button"].tap()
        
        XCTContext.runActivity(named: "[設定]NavigationBarの文言を確認") { (activity) in
            let navigationBar = app.navigationBars["設定"]
            XCTAssertTrue(navigationBar.exists)
        }
        
        XCTContext.runActivity(named: "[設定]セルの個数を確認") { (activity) in
            let cells = app.cells.matching(identifier: "SettingViewCell")
            XCTAssertEqual(cells.count, 5)
        }
        
        XCTContext.runActivity(named: "[設定]セルの文言を確認") { (activity) in
            let cells = app.cells.matching(identifier: "SettingViewCell")
            XCTAssertEqual(cells.element(boundBy: 0).staticTexts["テーマ"].label, "テーマ")
            XCTAssertEqual(cells.element(boundBy: 1).staticTexts["通知"].label, "通知")
            XCTAssertEqual(cells.element(boundBy: 2).staticTexts["データの引継ぎ"].label, "データの引継ぎ")
            XCTAssertEqual(cells.element(boundBy: 3).staticTexts["アプリの使い方"].label, "アプリの使い方")
            XCTAssertEqual(cells.element(boundBy: 4).staticTexts["お問い合わせ"].label, "お問い合わせ")
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
