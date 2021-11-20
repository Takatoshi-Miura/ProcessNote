//
//  TextViewCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

import UIKit

class TextViewCell: UITableViewCell, UITextViewDelegate {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var textView: UITextView!
    
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.text = ""
        // 枠線を追加
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     textViewに文字列をセット
     - Parameters:
        - string: 文字列
     */
    func setText(_ string: String) {
        textView.text = string
    }
}
