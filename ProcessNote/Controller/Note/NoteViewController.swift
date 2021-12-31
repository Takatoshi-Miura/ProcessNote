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
    func noteVCNoteDidTap(note: Note)
}


class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var tableView: UITableView!
    private var sectionTitle: [String] = [""]
    private var cellTitle: [[String]] = [[]]
    private var noteArray = [[Note]]()
    private var isAdMobShow: Bool = false
    var delegate: NoteViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        sectionTitle = getNoteYearAndMonth()
        noteArray = getNoteArrayForNoteView()
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
                self.sectionTitle = getNoteYearAndMonth()
                self.noteArray = getNoteArrayForNoteView()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                self.dismissIndicator()
            })
        } else {
            sectionTitle = getNoteYearAndMonth()
            noteArray = getNoteArrayForNoteView()
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
            let note = noteArray[selectedIndex!.section][selectedIndex!.row]
            if note.getIsDeleted() {
                noteArray[selectedIndex!.section].remove(at: selectedIndex!.row)
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
    func insertNote(note: Note) {
        let index: IndexPath = [0, 0]
        
        if !noteArray.isEmpty {
            // 同日のノートがあるなら追加しない
            if note.getCreated_at() == noteArray[0].first!.getCreated_at() {
                return
            }
            
            // セクション追加の必要性の判定(既存ノートと同じ年月かどうか)
            let realmNoteYearMonth = changeDateString(dateString: noteArray[0].first!.getCreated_at(), format: "yyyy-MM-dd", goalFormat: "yyyy-MM")
            let newNoteYearMonth = changeDateString(dateString: note.getCreated_at(), format: "yyyy-MM-dd", goalFormat: "yyyy-MM")
            if newNoteYearMonth == realmNoteYearMonth {
                noteArray[0].insert(note, at: 0)
                tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
            } else {
                sectionTitle.insert(getCreatedYearAndMonth(note: note), at: 0)
                noteArray.insert([note], at: 0)
                tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
            }
        } else {
            // 初めてノートを作成する場合(セクション&ノート追加)
            sectionTitle.insert(getCreatedYearAndMonth(note: note), at: 0)
            noteArray.insert([note], at: 0)
            tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
        }
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemGray6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionTitle[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noteArray.isEmpty {
            return 0
        }
        return noteArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noteDate = noteArray[indexPath.section][indexPath.row].getCreated_at()
        cell.textLabel?.text = changeDateString(dateString: noteDate, format: "yyyy-MM-dd", goalFormat: "MM / dd")
        cell.accessoryType = .disclosureIndicator // > 表示
        cell.accessibilityIdentifier = "NoteViewCell"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = noteArray[indexPath.section][indexPath.row]
        delegate?.noteVCNoteDidTap(note: note)
    }

}
