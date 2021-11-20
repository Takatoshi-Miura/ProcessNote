//
//  GroupHeaderView.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import UIKit

class GroupHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 枠線を追加
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.black.cgColor
    }
    
    func setProperty(group: Group) {
        imageView.backgroundColor = color[group.getColor()]
        
        titleLabel.text = group.getTitle()
        
        if group.getIsCompleted() {
            dateLabel.text = "\(group.getCreated_at())〜\(group.getCompleted_at())"
        } else {
            dateLabel.text = "\(group.getCreated_at())〜"
        }
    }

}
