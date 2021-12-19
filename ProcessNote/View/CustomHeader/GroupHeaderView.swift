//
//  GroupHeaderView.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/17.
//

import UIKit


protocol GroupHeaderViewDelegate: AnyObject {
    // ヘッダーをタップ時の処理
    func headerDidTap(view: GroupHeaderView)
    // infoボタンをタップ時の処理
    func infoButtonDidTap(view: GroupHeaderView)
}


class GroupHeaderView: UITableViewHeaderFooterView {
    
    // MARK: UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    var group = Group()
    var delegate: GroupHeaderViewDelegate?
    
    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = .systemGray6
        // タップジェスチャーを追加
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewDidTap(sender:))))
    }
    
    func setProperty(group: Group) {
        self.group = group
        imageView.backgroundColor = color[group.getColor()]
        titleLabel.text = group.getTitle()
        infoButton.tintColor = .systemBlue
    }
    
    @IBAction func infoButtonDidTap(_ sender: Any) {
        self.delegate?.infoButtonDidTap(view: self)
    }
    
    @objc func headerViewDidTap(sender: UITapGestureRecognizer) {
        self.delegate?.headerDidTap(view: self)
    }

}
