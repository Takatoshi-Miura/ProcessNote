//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit


protocol NoteViewControllerDelegate: AnyObject {
    // ハンバーガーメニューボタンタップ時の処理
    func noteVCHumburgerMenuButtonDidTap(_ viewController: NoteViewController)
}


class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex: IndexPath = [0, 0]
    var sectionTitle: [String] = []
    var cellTitle: [[String]] = [[]]
    var delegate: NoteViewControllerDelegate?
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        addRightSwipeGesture()
    }
    
    /// NavigationControllerの初期設定
    func initNavigationController() {
        self.title = NSLocalizedString("Note", comment: "")
        
        var menuButton: UIBarButtonItem
        let image = UITraitCollection.current.userInterfaceStyle == .dark ? UIImage(named: "humburger_menu_white")! : UIImage(named: "humburger_menu_black")!
        menuButton = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                                     style: .plain,
                                     target: self,
                                     action: #selector(openHumburgerMenu(_:)))
        navigationItem.leftBarButtonItems = [menuButton]
    }
    
    /// ハンバーガーメニューを表示
    @objc func openHumburgerMenu(_ sender: UIBarButtonItem) {
        self.delegate?.noteVCHumburgerMenuButtonDidTap(self)
    }
    
    /// 右スワイプでハンバーガーメニューを開く
    func addRightSwipeGesture() {
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(openHumburgerMenu(_:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
    }
    
    /// tableViewの初期設定
    func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isEditing = true  // 対策セルの常時並び替え許可
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // タップしたときの選択色を消去
        tableView.deselectRow(at: selectedIndex as IndexPath, animated: true)
    }
    
    /// ノート追加
    @IBAction func addButtonTap(_ sender: Any) {
        // TODO: ノート追加画面への遷移処理
    }
    
    
    // MARK: - 【Delegate】TableViewController

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellTitle[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    

}
