//
//  GroupHeaderView.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import UIKit


protocol GroupHeaderViewDelegate: AnyObject {
    func headerDidTap(view: GroupHeaderView)
}


class GroupHeaderView: UITableViewHeaderFooterView {
    
    // MARK: UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var group = Group()
    var delegate: GroupHeaderViewDelegate?
    
    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // 枠線を追加
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.black.cgColor
        // タップジェスチャーを追加
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewDidTap(sender:))))
    }
    
    func setProperty(group: Group) {
        self.group = group
        imageView.backgroundColor = color[group.getColor()]
        
        titleLabel.text = group.getTitle()
        
        if group.getIsCompleted() {
            dateLabel.text = "\(group.getCreated_at())〜\(group.getCompleted_at())"
        } else {
            dateLabel.text = "\(group.getCreated_at())〜"
        }
    }
    
    @objc func headerViewDidTap(sender: UITapGestureRecognizer) {
        self.delegate?.headerDidTap(view: self)
    }

}
