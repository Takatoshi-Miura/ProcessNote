//
//  NoteCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2022/01/08.
//

import UIKit

class NoteCell: UITableViewCell {
    
    // MARK: UI,Variable
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var groupColorView: UIImageView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setProperty(memo: Memo) {
        let group = getGroup(memo: memo)
        let measures = getMeasures(measuresID: memo.getMeasuresID())
        let task = getTask(taskID: measures.getTaskID())
        let date = memo.getCreated_at()
        detailLabel.text = memo.getDetail()
        groupColorView.backgroundColor = color[group.getColor()]
        taskTitleLabel.text = task.getTitle()
        dateLabel.text = changeDateString(dateString: date, format: "yyyy-MM-dd HH:mm:ss", goalFormat: "yyyy/MM/dd")
    }
    
}
