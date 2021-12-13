//
//  ColorCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/16.
//

import UIKit

class ColorCell: UITableViewCell {
    
    // MARK: - UI,Variable
    
    var delegate: ColorCellDelegate? = nil
    @IBOutlet weak var colorButton: UIButton!
    
    @IBAction func tapColorButton(_ sender: Any) {
        delegate?.tapColorButton(colorButton)
    }
    
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 枠線を追加
        colorButton.layer.borderWidth = 0.5
        colorButton.layer.borderColor = UIColor.black.cgColor
        colorButton.layer.cornerRadius = 5.0
    }
    
    /**
     色をセット
     - Parameters:
       - colorNum: 色番号
     */
    func setColor(_ colorNum: Int) {
        colorButton.backgroundColor = color[colorNum]
        if colorNum == 7 {
            colorButton.setTitleColor(UIColor.black, for: .normal)
        } else {
            colorButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    /**
     文字列をセット
     - Parameters:
     - string: 文字列
     */
    func setTitle(_ string: String) {
        colorButton.setTitle(string, for: .normal)
    }
}


// MARK: - 【Delegate】ColorCellDelegate

protocol ColorCellDelegate {
    func tapColorButton(_ button: UIButton)
}
