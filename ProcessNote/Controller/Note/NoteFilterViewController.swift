//
//  NoteFilterViewController.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/01/22.
//

import UIKit

protocol NoteFilterViewControllerDelegate: AnyObject {
    // キャンセルボタンタップ時の処理
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController)
}

class NoteFilterViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    var delegate: NoteFilterViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        delegate?.noteFilterVCCancelDidTap(self)
    }
    
    
}
