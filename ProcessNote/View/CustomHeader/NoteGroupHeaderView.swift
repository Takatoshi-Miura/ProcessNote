//
//  NoteGroupHeaderView.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/12/11.
//

import UIKit


class NoteGroupHeaderView: UITableViewHeaderFooterView {
    
    // MARK: UI,Variable
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = .systemGray6
    }
    
    func setProperty(group: Group) {
        imageView.backgroundColor = color[group.getColor()]
        label.text = group.getTitle()
    }

}
