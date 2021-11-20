//
//  TitleCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import UIKit

class TitleCell: UITableViewCell {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 枠線を追加
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     textFieldに文字列をセット
     - Parameters:
        - title: 文字列
     */
    func setTitle(_ title: String) {
        textField.text = title
    }
}
