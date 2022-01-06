//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import GoogleMobileAds


protocol NoteViewControllerDelegate: AnyObject {
    // ノート追加ボタンタップ時の処理
    func noteVCAddButtonDidTap(_ viewController: NoteViewController)
    // ノートタップ時の処理
    func noteVCMemoDidTap(memo: Memo)
}


class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var tableView: UITableView!
    private var cellTitle: [[String]] = [[]]
    private var memoArray = [Memo]()
    private var isAdMobShow: Bool = false
    var delegate: NoteViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        memoArray = getMemoArrayForNoteView()
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            showIndicator(message: MESSAGE_SERVER_COMMUNICATION)
            syncDatabase(completion: {
                self.memoArray = getMemoArrayForNoteView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            memoArray = getMemoArrayForNoteView()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAdMob()
        
        let selectedIndex: IndexPath? = tableView.indexPathForSelectedRow
        if (selectedIndex != nil) {
            // 削除されている場合は一覧から取り除く
            let memo = memoArray[selectedIndex!.row]
            if memo.getIsDeleted() {
                memoArray.remove(at: selectedIndex!.row)
                tableView.deleteRows(at: [selectedIndex!], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex!], with: .none)
        }
    }
    
    /// ノート追加
    @IBAction func addButtonTap(_ sender: Any) {
        if getAllMeasures(isDeleted: false).isEmpty {
            showErrorAlert(message: MESSAGE_EMPTY_MEASURES)
            return
        }
        self.delegate?.noteVCAddButtonDidTap(self)
    }
    
    /**
     ノートを挿入
     - Parameters:
        - note: 挿入するノート
     */
    func insertMemo(memo: Memo) {
        let index: IndexPath = [0, 0]
        memoArray.insert(memo, at: 0)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
    /// バナー広告を表示
    func showAdMob() {
        if isAdMobShow { return }
        
        // バナー広告を宣言
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize: GADAdSizeBanner)
        admobView.adUnitID = "ca-app-pub-9630417275930781/9800556170"
        admobView.rootViewController = self
        admobView.load(GADRequest())
        
        // レイアウト調整(画面下部に設置)
        admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height)
        admobView.frame.size = CGSize(width: self.view.frame.width, height: admobView.frame.height)
        
        self.view.addSubview(admobView)
        isAdMobShow = true
    }
    
}
    

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoArray.isEmpty {
            return 0
        }
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = memoArray[indexPath.row].getDetail()
        cell.detailTextLabel?.text = memoArray[indexPath.row].getCreated_at()
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memoArray[indexPath.row]
        delegate?.noteVCMemoDidTap(memo: memo)
    }

}
