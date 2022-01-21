//
//  NoteViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/05.
//

import UIKit
import GoogleMobileAds
import PKHUD


protocol NoteViewControllerDelegate: AnyObject {
    // ノート追加ボタンタップ時の処理
    func noteVCAddButtonDidTap(_ viewController: NoteViewController)
    // ノートタップ時の処理
    func noteVCMemoDidTap(memo: Memo)
    // フィルターボタンタップ時の処理
    func noteVCFilterDidTap(_ viewController: NoteViewController)
}


class NoteViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: UIView!
    private var memoArray = [Memo]()
    private var isFiltered: Bool = false
    private var adMobView: GADBannerView?
    var delegate: NoteViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initSearchBar()
        initTableView()
        memoArray = getMemoArrayForNoteView()
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
        let filterButton = UIBarButtonItem(image: UIImage(named: "icon_filter_empty")!, style: .done, target: self, action: #selector(filterNote))
        navigationItem.rightBarButtonItems = [filterButton]
    }
    
    /// ノートの絞り込み
    @objc func filterNote() {
        delegate?.noteVCFilterDidTap(self)
    }
    
    func initSearchBar() {
        searchBar.delegate = self
        searchBar.searchTextField.placeholder = TITLE_SEARCH_NOTE
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            syncDatabase(completion: {
                self.memoArray = getMemoArrayForNoteView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                HUD.hide()
            })
        } else {
            memoArray = getMemoArrayForNoteView()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    /// バナー広告を表示
    func showAdMob() {
        if let adMobView = adMobView {
            adMobView.frame.size = CGSize(width: self.view.frame.width, height: adMobView.frame.height)
            return
        }
        adMobView = GADBannerView()
        adMobView = GADBannerView(adSize: GADAdSizeBanner)
        adMobView!.adUnitID = "ca-app-pub-9630417275930781/9800556170"
        adMobView!.rootViewController = self
        adMobView!.load(GADRequest())
        adMobView!.frame.origin = CGPoint(x: 0, y: 0)
        adMobView!.frame.size = CGSize(width: self.view.frame.width, height: adMobView!.frame.height)
        self.adView.addSubview(adMobView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 削除されている場合は一覧から取り除く
            let memo = memoArray[selectedIndex.row]
            if memo.getIsDeleted() {
                memoArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
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
     メモを挿入
     - Parameters:
        - memo: 挿入するメモ
     */
    func insertMemo(memo: Memo) {
        let index: IndexPath = [0, 0]
        memoArray.insert(memo, at: 0)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
}


extension NoteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            memoArray = getMemoArrayForNoteView()
        } else {
            memoArray = searchMemo(searchWord: searchBar.text!)
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        cell.setProperty(memo: memoArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memoArray[indexPath.row]
        delegate?.noteVCMemoDidTap(memo: memo)
    }

}
