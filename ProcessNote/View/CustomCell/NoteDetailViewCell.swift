//
//  NoteDetailViewCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/11.
//

import UIKit

class NoteDetailViewCell: UITableViewCell {
    
    // MARK: UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     ラベルに文字列をセット(ノート閲覧用)
     - Parameters:
        - task: 課題
        - measure: 対策
     */
    func setLabelText(task: Task, measure: Measures, detail: Memo) {
        titleLabel.text = task.getTitle()
        measuresLabel.text = "\(NSLocalizedString("Measures", comment: ""))：\(measure.getTitle())"
        detailLabel.text = detail.getDetail()
    }
    
}
