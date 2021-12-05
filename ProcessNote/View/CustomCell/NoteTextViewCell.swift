//
//  NoteTextViewCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/04.
//

import UIKit

class NoteTextViewCell: UITableViewCell, UITextViewDelegate {
    
    // MARK: - UI,Variable
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var measures: UILabel!
    @IBOutlet weak var memo: UITextView!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        memo.text = ""
        // 枠線を追加
        memo.layer.borderWidth = 0.5
        memo.layer.borderColor = UIColor.black.cgColor
        memo.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     ラベルに文字列をセット
     - Parameters:
        - task: 課題
     */
    func setLabelText(_ task: Task) {
        title.text = task.getTitle()
        let measure = getMeasuresInTask(ID: task.getTaskID()).first!
        measures.text = "\(NSLocalizedString("Measures", comment: ""))：\(measure.getTitle())"
    }
    
    /**
     ラベルに文字列をセット(ノート閲覧用)
     - Parameters:
        - task: 課題
        - measure: 対策
     */
    func setLabelText(task: Task, measure: Measures, detail: Memo) {
        title.text = task.getTitle()
        measures.text = "\(NSLocalizedString("Measures", comment: ""))：\(measure.getTitle())"
        memo.text = detail.getDetail()
    }
}
