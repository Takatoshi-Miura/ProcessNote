//
//  SettingCell.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/20.
//

import UIKit

class SettingCell: UITableViewCell {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setText(_ text: String) {
        label.text = text
    }
    
    func setIconImage(_ image: UIImage) {
        iconImage.image = image
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
